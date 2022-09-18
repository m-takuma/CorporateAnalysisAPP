//
//  SearchViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Takuma on 2021/12/12.
//

import UIKit
import RealmSwift
import GoogleMobileAds
import FirebaseAuth
import AdSupport
import AppTrackingTransparency
import Alamofire

protocol PuchCompanyDataVCDelegate:AnyObject{
    func presentCompanyVC(company:CompanyDataClass)
}

class SearchViewController: UIViewController{
    private enum SearchSection:Int,Hashable,CaseIterable{
        case outline
    }
    
    private enum Category:Hashable, CaseIterable, CustomStringConvertible{
        case history
        case nikkei225
        case topixCore30
        var description: String {
            switch self {
            case .history: return "検索履歴"
            case .nikkei225: return "N225"
            case .topixCore30: return "TPX大型株30"
            }
        }
    }
    private struct Item: Hashable {
        private let identifier = UUID()
        let name: String?
        let secCode:String?
        let type:CellType!
        
        init(name:String? = "",secCode:String? = "",type:CellType){
            self.name = name
            self.secCode = secCode
            self.type = type
        }
        enum CellType{
            case cell
            case header
        }
    }
    
    private var searchController:UISearchController!
    
    private var dataSource: UICollectionViewDiffableDataSource<SearchSection, Item>! = nil
    var token:NotificationToken? = nil
    
    private var collectionView:UICollectionView!
    private var bannerView:GADBannerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.systemGroupedBackground
        configNotificationToken()
        configSearchReslutsController()
        configNavItem()
        configureCollectionView()
        configBannerView()
        configAutoLayout()
        configureDataSource()
        applySnapshots()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Task{
            try await AuthSignInClass().sigInAnoymously()
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        ATTrackingManager.requestTrackingAuthorization { status in
        }
    }
    
    private func configBannerView(){
        bannerView = GADBannerView()
        bannerView.adUnitID = GoogleAdUnitID_Banner
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(view.frame.width)
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        bannerView.load(GADRequest())
    }
    
    // データバインディング用のToken設定
    private func configNotificationToken(){
        let realm = try! Realm()
        let fav = realm.object(ofType: CategoryRealm.self, forPrimaryKey: "History")!.list
        self.token = fav.observe({(change:RealmCollectionChange) in
            switch change {
            case .initial:
                return
            case .update:
                self.dataSource = nil
                self.configureDataSource()
                self.applySnapshots()
                self.collectionView.reloadData()
            case .error(let error):
                print(error)
            }
        })
    }
    
    private func configSearchReslutsController(){
        let resultController = SearchReslutsViewController()
        resultController.delegate = self
        searchController = UISearchController(searchResultsController: resultController)
        searchController.searchBar.delegate = resultController
        searchController.searchBar.searchTextField.delegate = resultController
        searchController.searchResultsUpdater = resultController
        searchController.definesPresentationContext = true
        searchController.showsSearchResultsController = true
        searchController.searchBar.placeholder = "会社名または証券コード"
    }
    
    private func configNavItem(){
        navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "検索"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureCollectionView(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: configureCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        view.addSubview(collectionView)
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout{
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment
        ) -> NSCollectionLayoutSection? in
            guard let sectionKind = SearchSection(rawValue: sectionIndex) else { return nil }
            var section: NSCollectionLayoutSection! = nil
            switch sectionKind {
            case .outline:
                section = NSCollectionLayoutSection.list(using: .init(appearance: .insetGrouped), layoutEnvironment: layoutEnvironment)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            }
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func configAutoLayout(){
        bannerView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: 0
        ).isActive = true
        
        bannerView.centerXAnchor.constraint(
            equalTo: view.centerXAnchor
        ).isActive = true
        
        collectionView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -(bannerView.frame.height + 12)
        ).isActive = true
        
        collectionView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor
        ).isActive = true
        
        collectionView.rightAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.rightAnchor
        ).isActive = true
        
        collectionView.leftAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.leftAnchor
        ).isActive = true
    }
}
/// collectionViewのDataの設定
extension SearchViewController{
    private func configureDataSource(){
        let historyCellRegistration = createHistoryCellRegistration()
        let headerCellRegistration = createOutlineHeaderCellRegistration()
        dataSource = UICollectionViewDiffableDataSource<SearchSection, Item>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
            guard let section = SearchSection(rawValue: indexPath.section)
                else { fatalError("Unknown section") }
            switch section {
            case .outline:
                if item.type == .header{
                    return collectionView.dequeueConfiguredReusableCell(
                        using: headerCellRegistration,
                        for: indexPath,
                        item: item)
                }
                return collectionView.dequeueConfiguredReusableCell(
                    using: historyCellRegistration,
                    for: indexPath,
                    item: item)
            }
        })
    }
    private func createHistoryCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item>{
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item>{
            [weak self] (cell,indexPath,itemIdentifier) in
            guard self != nil else { return }
            var content = UIListContentConfiguration.subtitleCell()
            content.text = itemIdentifier.name
            content.secondaryText = itemIdentifier.secCode
            cell.contentConfiguration = content
        }
    }
    
    
    private func createOutlineHeaderCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item>
        { (cell, indexPath, item) in
            var content = UIListContentConfiguration.sidebarHeader()
            content.text = item.name
            content.textProperties.font = .boldSystemFont(ofSize: 20)
            let back = UIBackgroundConfiguration.listPlainHeaderFooter()
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
            cell.backgroundConfiguration = back
        }
    }
    
    private func applySnapshots() {
        let sections = SearchSection.allCases
        var snapshot = NSDiffableDataSourceSnapshot<SearchSection, Item>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        var outlineSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        
        let realm = try! Realm()
        
        for category in Category.allCases{
            let rootItem = Item(name: String(describing: category),type: .header)
            outlineSnapshot.append([rootItem])
            var items:Array<SearchViewController.Item> = []
            switch category{
            case .history:
                if let obj = realm.object(
                    ofType: CategoryRealm.self,
                    forPrimaryKey: "History")
                {
                    for co in Array(obj.list){
                        let item = Item(
                            name: co.simpleCompanyName,
                            secCode: co.secCode,
                            type: .cell)
                        items.append(item)
                    }
                }
            case .nikkei225:
                if let obj = realm.object(
                    ofType: CategoryRealm.self,
                    forPrimaryKey: "N225")
                {
                    for co in Array(obj.list){
                        let item = Item(
                            name: co.simpleCompanyName,
                            secCode: co.secCode,
                            type: .cell)
                        items.append(item)
                    }
                }
            case .topixCore30:
                if let obj = realm.object(
                    ofType: CategoryRealm.self,
                    forPrimaryKey: "Core30")
                {
                    for co in Array(obj.list){
                        let item = Item(
                            name: co.simpleCompanyName,
                            secCode: co.secCode,
                            type: .cell)
                        items.append(item)
                    }
                }
            }
            outlineSnapshot.append(items, to: rootItem)
        }
        dataSource.apply(
            outlineSnapshot,
            to: .outline,
            animatingDifferences: false)
    }
}

extension SearchViewController: PuchCompanyDataVCDelegate{
    func presentCompanyVC(company:CompanyDataClass){
        let CompanyVC = CompanyRootTestViewController()
        CompanyVC.company = company
        navigationController?.pushViewController(CompanyVC, animated: true)
    }
}

extension SearchViewController:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            let aleart = UIAlertController(title: "予期しないエラーが発生しました",
                                           message: "",
                                           preferredStyle: .alert)
            aleart.addAction(UIAlertAction(title: "閉じる", style: .default))
            present(aleart, animated: true, completion: nil)
            return
        }
        if let searchText = item.secCode{
            searchController.searchBar.text = searchText
        }else{
            searchController.searchBar.text = item.name
        }
        searchController.isActive = true
        searchController.searchBar.delegate?.searchBarSearchButtonClicked!(searchController.searchBar)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension SearchViewController: GADBannerViewDelegate{
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1) {
            bannerView.alpha = 1
        }
    }
}
