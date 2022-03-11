//
//  SearchViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2021/12/12.
//

import UIKit
import FirebaseFirestore
import RealmSwift

class SearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UITextFieldDelegate,UISearchControllerDelegate,PuchCompanyDataVCDelegate{
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "検索"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        self.view.addSubview(tableView)
        self.tableView.frame = self.view.bounds

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
    func presentView(company:CompanyDataClass){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let CompanyVC = storyboard.instantiateViewController(withIdentifier: "CompanyVC") as! CompanyViewController
        CompanyVC.company = company
        self.navigationController?.pushViewController(CompanyVC, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class SearchReslutsViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UITextFieldDelegate,UISearchResultsUpdating{
    
    var db:Firestore!
    var resultArray:Array<SearchBasicIndex> = []
    
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
        indicator.color = .black
        
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
        cell.textLabel?.text = company.jpCompanyName!
        cell.detailTextLabel?.text = company.secCode!
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
        self.view.addSubview(indicator)
        indicator.startAnimating()
        db.collection("COMPANY_v2").document(resultArray[indexPath.row].jcn!).getDocument{ doc, err in
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
        self.view.addSubview(indicator)
        indicator.startAnimating()
        self.resultArray = []
        let realm = try! Realm()
        if Int(searchBar.searchTextField.text!) != nil{
            let searchText = searchBar.searchTextField.text!
            let results = realm.objects(SearchBasicIndex.self).filter("secCode CONTAINS '\(searchText)'")
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
                let results = realm.objects(SearchBasicIndex.self).filter("jpCompanyName CONTAINS '\(searchText)'")
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
