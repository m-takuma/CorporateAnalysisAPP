//
//  SearchViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2021/12/12.
//

import UIKit
import FirebaseFirestore
import RealmSwift
import GoogleMobileAds
import FirebaseAuth
import AdSupport
import AppTrackingTransparency

protocol PuchCompanyDataVCDelegate:AnyObject{
    func presentView(company:CompanyDataClass)
}

class SearchViewController: UIViewController,PuchCompanyDataVCDelegate{
    
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
        configToken()
        configSearchController()
        configNavItem()
        configureCollectionView()
        configureDataSource()
        applySnapshots()
        configBannerView()
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
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        // TODO: テスト用のIDになっている
        bannerView.adUnitID = GoogleAdUnitID_TEST_Banner
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [GADSimulatorID]
        
        bannerView.rootViewController = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
            
            ])
        view.addSubview(bannerView)
        bannerView.load(GADRequest())
    }
    
    private func configToken(){
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
    
    private func configSearchController(){
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
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: configureCollectionViewLayout())
        collectionView.autoresizingMask = [.flexibleWidth,.flexibleBottomMargin,.flexibleTopMargin]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.view.addSubview(collectionView)
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout{
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionKind = SearchSection(rawValue: sectionIndex) else { return nil }
            var section: NSCollectionLayoutSection! = nil
            switch sectionKind {
            case .outline:
                section = NSCollectionLayoutSection.list(using: .init(appearance: .sidebar), layoutEnvironment: layoutEnvironment)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            }
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    private func configureDataSource(){
        let historyCellRegistration = createHistoryCellRegistration()
        let headerCellRegistration = createOutlineHeaderCellRegistration()
        dataSource = UICollectionViewDiffableDataSource<SearchSection, Item>.init(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, item in
            guard let section = SearchSection(rawValue: indexPath.section) else { fatalError("Unknown section") }
            switch section {
            case .outline:
                if item.type == .header{
                    return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: item)
                }
                return collectionView.dequeueConfiguredReusableCell(using: historyCellRegistration, for: indexPath, item: item)
            }
        })
    }
    private func createHistoryCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item>{
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item>.init { [weak self] (cell,indexPath,itemIdentifier) in
            guard let self = self else { return }
            var content = UIListContentConfiguration.accompaniedSidebarSubtitleCell()
            content.text = itemIdentifier.name
            content.secondaryText = itemIdentifier.secCode
            //var background = UIBackgroundConfiguration.listSidebarCell()
            cell.contentConfiguration = content
            //cell.backgroundConfiguration = background
        }
    }
    
    
    private func createOutlineHeaderCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.name
            content.textProperties.font = .boldSystemFont(ofSize: 20)
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
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
            if category == .history{
                if let obj = realm.object(ofType: CategoryRealm.self, forPrimaryKey: "History"){
                    for co in Array(obj.list){
                        let item = Item(name: co.simpleCompanyName, secCode: co.secCode, type: .cell)
                        items.append(item)
                    }
                }
            }else if category == .nikkei225{
                if let obj = realm.object(ofType: CategoryRealm.self, forPrimaryKey: "N225"){
                    for co in Array(obj.list){
                        let item = Item(name: co.simpleCompanyName, secCode: co.secCode, type: .cell)
                        items.append(item)
                    }
                }
            }else if category == .topixCore30{
                if let obj = realm.object(ofType: CategoryRealm.self, forPrimaryKey: "Core30"){
                    for co in Array(obj.list){
                        let item = Item(name: co.simpleCompanyName, secCode: co.secCode, type: .cell)
                        items.append(item)
                    }
                }
            }
            
            outlineSnapshot.append(items, to: rootItem)
        }
        dataSource.apply(outlineSnapshot, to: .outline, animatingDifferences: false)
    }

    func presentView(company:CompanyDataClass){
        let CompanyVC = CompanyRootViewController()
        CompanyVC.company = company
        self.navigationController?.pushViewController(CompanyVC, animated: true)
    }
    
}

extension SearchViewController:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            let aleart = UIAlertController(title: "予期しないエラーが発生しました", message: "", preferredStyle: .alert)
            aleart.addAction(UIAlertAction(title: "閉じる", style: .default))
            present(aleart, animated: true, completion: nil)
            return
        }
        if let searchText = item.secCode{
            self.searchController.searchBar.text = searchText
        }else{
            self.searchController.searchBar.text = item.name
        }
        self.searchController.isActive = true
        self.searchController.searchBar.delegate?.searchBarSearchButtonClicked!(searchController.searchBar)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

class SearchReslutsViewController:UIViewController,UISearchBarDelegate,UITextFieldDelegate{
    
    weak var delegate:PuchCompanyDataVCDelegate? = nil
 
    private var db:Firestore!
    
    private var resultArray:Array<CompanyRealm> = []
    
    private var tableView:UITableView!
    
    private var indicator:UIActivityIndicatorView!

    private var aleart:UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        configTableView()
        configIndicator()
        configAleart()
        configFirestore()
    }
    
    private func configTableView(){
        self.tableView = UITableView(frame: self.view.bounds)
        tableView.autoresizingMask = [.flexibleWidth,.flexibleHeight,.flexibleBottomMargin,.flexibleTopMargin]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.bounces = true
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        self.view.addSubview(tableView)
    }
    
    private func configIndicator(){
        indicator = UIActivityIndicatorView()
        indicator.frame = self.view.bounds
        indicator.center = self.view.center
        indicator.autoresizingMask = [.flexibleWidth,.flexibleHeight,.flexibleBottomMargin,.flexibleTopMargin]
        indicator.style = UIActivityIndicatorView.Style.large
    }
    
    private func configAleart(){
        aleart = UIAlertController(title: "見つかりませんでした", message: "該当する会社はありません。条件を変更して検索してください", preferredStyle: .alert)
        aleart.addAction(UIAlertAction(title: "閉じる", style: .default))
    }
    
    private func configFirestore(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
    }
    
    func presentView(company:CompanyDataClass){
        self.indicator.stopAnimating()
        indicator.removeFromSuperview()
        self.delegate?.presentView(company: company)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.search(searchBar:searchBar)
    }
    
    func search(searchBar: UISearchBar) {
        self.view.addSubview(indicator)
        indicator.startAnimating()
        self.resultArray = []
        let realm = try! Realm()
        if Int(searchBar.searchTextField.text!) != nil{
            let searchText = searchBar.searchTextField.text!
            let results = realm.objects(CompanyRealm.self).filter("secCode CONTAINS '\(searchText)'")
            if results.count == 0{
                self.present(self.aleart, animated: true, completion: nil)
            }else{
                resultArray = Array(results)
                self.tableView.reloadData()
            }
            
        }else{
            if searchBar.searchTextField.text! == ""{
                self.indicator.stopAnimating()
                indicator.removeFromSuperview()
                return
            }else{
                var searchText = searchBar.searchTextField.text!
                searchText = searchText.applyingTransform(.fullwidthToHalfwidth, reverse: true)!
                let results = realm.objects(CompanyRealm.self).filter("simpleCompanyName CONTAINS '\(searchText)'")
                if results.count == 0{
                    self.present(self.aleart, animated: true, completion: nil)
                }else{
                    resultArray = Array(results)
                    self.tableView.reloadData()
                }
            }
            
        }
        self.indicator.stopAnimating()
        indicator.removeFromSuperview()
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
    }
}

extension SearchReslutsViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let company = resultArray[indexPath.row]
        cell.textLabel?.text = company.simpleCompanyName
        cell.detailTextLabel?.text = company.secCode
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let company = resultArray[indexPath.row]
        self.view.endEditing(true)
        self.view.addSubview(indicator)
        indicator.startAnimating()
        saveHistory(company: company)
        fetchCompany(company: company)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func saveHistory(company:CompanyRealm){
        let realm = try! Realm()
        if let fav = realm.object(ofType: CategoryRealm.self, forPrimaryKey: "History"){
            try! realm.write{
                if let index = fav.list.index(of: company){
                    fav.list.remove(at: index)
                    fav.list.insert(company, at: 0)
                }else{
                    fav.list.insert(company, at: 0)
                }
                if fav.list.count > 20{
                    fav.list.removeLast()
                }
            }
        }
    }
    
    private func fetchCompany(company:CompanyRealm){
        Task{
            do{
                let ref = db.collection("COMPANY_v2").document(company.jcn!)
                let doc = try await FireStoreFetchDataClass().getDocument(ref: ref)
                let core = CompanyCoreDataClass(companyCoreDataDic: doc.data()!)
                let company = try await FireStoreFetchDataClass().makeCompany_v2(for: core)
                self.presentView(company: company)
            }catch let err{
                self.indicator.stopAnimating()
                self.indicator.removeFromSuperview()
                let aleart = UIAlertController(title: "エラーが発生しました", message: "お手数ですが、通信状況を確認してもう一度行ってください[\(err.localizedDescription)]", preferredStyle: .alert)
                aleart.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                self.present(aleart, animated: true, completion: nil)
            }
        }
    }
}

extension SearchReslutsViewController:UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
