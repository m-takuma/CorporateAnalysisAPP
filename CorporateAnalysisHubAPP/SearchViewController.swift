//
//  SearchViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2021/12/12.
//

import UIKit
import FirebaseFirestore
import RealmSwift

class SearchViewController: UIViewController,UISearchBarDelegate,UITextFieldDelegate,UISearchControllerDelegate,PuchCompanyDataVCDelegate, UICollectionViewDelegate{
    
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
    
    lazy var searchController:UISearchController = { () -> UISearchController in
        let resultController = SearchReslutsViewController()
        resultController.delegate = self
        let controller = UISearchController(searchResultsController: resultController)
        controller.searchBar.delegate = resultController
        controller.searchBar.searchTextField.delegate = resultController
        controller.searchResultsUpdater = resultController
        controller.definesPresentationContext = true
        controller.showsSearchResultsController = true
        controller.searchBar.placeholder = "会社名または証券コード"
        return controller
        
    }()
    
    var collectionView:UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "検索"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        configureCollectionView()
        configureDataSource()
        applyInitialSnapshots()

        // Do any additional setup after loading the view.
    }
    
    private func configureCollectionView(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: configureCollectionViewLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
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
            if sectionKind == .outline {
                
            }else{
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                configuration.headerMode = .firstItemInSection
                section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
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
    private var dataSource: UICollectionViewDiffableDataSource<SearchSection, Item>! = nil
    private func applyInitialSnapshots() {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
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

class SearchReslutsViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UITextFieldDelegate,UISearchResultsUpdating{
    
    
    
    var db:Firestore!
    var resultArray:Array<CompanyRealm> = []
    
    weak var delegate:PuchCompanyDataVCDelegate? = nil
    
    lazy var tableView:UITableView = { () -> UITableView in
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.bounces = true
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.keyboardDismissMode = .onDrag
        return tableView
        
    }()
    
    lazy var indicator = {() -> UIActivityIndicatorView in
        let indicator = UIActivityIndicatorView()
        indicator.center = self.view.center
        indicator.style = UIActivityIndicatorView.Style.large
        
        return indicator
    }()
    
    let aleart = UIAlertController(title: "見つかりませんでした", message: "該当する会社はありません。条件を変更して検索してください", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        aleart.addAction(UIAlertAction(title: "閉じる", style: .default))
        self.view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        self.tableView.frame = self.view.bounds
    }
    
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
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
        indicator.frame = self.view.bounds
        self.view.addSubview(indicator)
        indicator.startAnimating()
        db.collection("COMPANY_v2").document(company.jcn!).getDocument{ doc, err in
            if let err = err {
                self.indicator.stopAnimating()
                self.indicator.removeFromSuperview()
                print("Error getting documents:\(err)")
            }else{
                Task{
                    let core = CompanyCoreDataClass(companyCoreDataDic: doc!.data()!)
                    let company = try await self.makeCompany_v2(for: core)
                    self.presentView(company: company)
                }
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
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
    func makeCompany_v2(for coreData:CompanyCoreDataClass) async throws -> CompanyDataClass{
        guard coreData.JCN != nil else {
            throw CustomError.NoneJCN
        }
        let docRef = db.collection("COMPANY_v2").document(coreData.JCN).collection("FinDoc")
        let company = CompanyDataClass.init(coreData: coreData)
        do{
            let snapShot = try await getDocuments(ref: docRef)
            for doc in snapShot.documents{
                let docData = DocData(docID: doc.documentID, companyFinData: doc.data())
                company.finDataDict[doc.documentID] = docData
                let bsSnapShot = try await getDocument(ref:docRef.document(doc.documentID).collection("FinData").document("BS"))
                let plSnapShot = try await getDocument(ref:docRef.document(doc.documentID).collection("FinData").document("PL"))
                let cfSnapShot = try await getDocument(ref:docRef.document(doc.documentID).collection("FinData").document("CF"))
                let otherSnapShot = try await getDocument(ref:docRef.document(doc.documentID).collection("FinData").document("Other"))
                let finIndexSnapShot = try await getDocument(ref:docRef.document(doc.documentID).collection("FinData").document("FinIndexPath"))
                docData.bs = CompanyBSCoreData(bs: bsSnapShot.data()!)
                docData.pl = CompanyPLCoreData(pl: plSnapShot.data()!)
                docData.cf = CompanyCFCoreData(cf: cfSnapShot.data()!)
                docData.other = CompanyOhterData(other: otherSnapShot.data()!)
                docData.finIndex = CompanyFinIndexData(indexData: finIndexSnapShot.data()!)
            }
            return company
        }catch{
            throw CustomError.NoneSnapShot
        }
    }
    
    func getDocuments(ref:CollectionReference) async throws -> QuerySnapshot{
        try await withCheckedThrowingContinuation({ continuation in
            ref.getDocuments { querySnapshot, err in
                if err != nil || querySnapshot == nil{
                    continuation.resume(throwing: CustomError.NoneSnapShot)
                }else{
                    continuation.resume(returning: querySnapshot!)
                }}})}
    func getDocument(ref:DocumentReference) async throws -> DocumentSnapshot{
        try await withCheckedThrowingContinuation({ continuation in
            ref.getDocument { doc, err in
                if err != nil || doc == nil{
                    continuation.resume(throwing: CustomError.NoneSnapShot)
                }else{
                    continuation.resume(returning: doc!)
                }}})}
}

protocol PuchCompanyDataVCDelegate:AnyObject{
    func presentView(company:CompanyDataClass)
}


