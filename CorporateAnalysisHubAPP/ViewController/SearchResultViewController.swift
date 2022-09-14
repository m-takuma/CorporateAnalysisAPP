//
//  SearchResultViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/09/14.
//

import UIKit
import FirebaseFirestore
import RealmSwift


class SearchReslutsViewController:UIViewController,UISearchBarDelegate,UITextFieldDelegate{
    
    weak var delegate:PuchCompanyDataVCDelegate? = nil
 
    private var db:Firestore!
    
    private var resultArray:Array<ApiCompany> = []
    
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
        db = Firestore.firestore()
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
        //let realm = try! Realm()
        if Int(searchBar.searchTextField.text!) != nil{
            let searchText = searchBar.searchTextField.text!
            Task{
                let companyRes = try? await companyFind(q: searchText, type: .sec_code)
                guard let companyList = companyRes?.results else{
                    self.indicator.stopAnimating()
                    indicator.removeFromSuperview()
                    return
                }
                if companyList.count == 0{
                    self.indicator.stopAnimating()
                    indicator.removeFromSuperview()
                    return
                }else{
                    resultArray = companyList
                    self.tableView.reloadData()
                }
            }
        }else{
            if searchBar.searchTextField.text! == ""{
                self.indicator.stopAnimating()
                indicator.removeFromSuperview()
                return
            }else{
                var searchText = searchBar.searchTextField.text!
                searchText = searchText.applyingTransform(.fullwidthToHalfwidth, reverse: true)!
                Task{
                    let companyRes = try? await companyFind(q: searchText, type: .name_jp)
                    guard let companyList = companyRes?.results else{
                        self.indicator.stopAnimating()
                        indicator.removeFromSuperview()
                        return
                    }
                    if companyList.count == 0{
                        self.indicator.stopAnimating()
                        indicator.removeFromSuperview()
                        return
                    }else{
                        resultArray = companyList
                        self.tableView.reloadData()
                    }
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
        cell.textLabel?.text = company.name_jp
        cell.detailTextLabel?.text = company.sec_code
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
    
    private func saveHistory(company:ApiCompany){
        let realm = try! Realm()
        var companyRealm = realm.object(ofType: CompanyRealm.self, forPrimaryKey: company.jcn)
        if companyRealm == nil{
            companyRealm = CompanyRealm(jcn: company.jcn, secCode: company.sec_code, simpleName: company.name_jp)
        }
        if let fav = realm.object(ofType: CategoryRealm.self, forPrimaryKey: "History"){
            try! realm.write{
                if let index = fav.list.index(of: companyRealm!){
                    fav.list.remove(at: index)
                    fav.list.insert(companyRealm!, at: 0)
                }else{
                    fav.list.insert(companyRealm!, at: 0)
                }
                if fav.list.count > 20{
                    fav.list.removeLast()
                }
            }
        }
    }
    
    private func fetchCompany(company:ApiCompany){
        Task{
            do{
                let ref = db.collection("COMPANY_v2").document(company.jcn)
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
