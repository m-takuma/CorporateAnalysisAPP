//
//  SearchResultViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/09/14.
//

import UIKit
import FirebaseFirestore
import RealmSwift


class SearchReslutsViewController:UIViewController{
    
    weak var delegate:PuchCompanyDataVCDelegate? = nil
    private var db:Firestore!
    private var resultArray:Array<ApiCompany> = []
    private var tableView:UITableView!
    private var indicator:UIActivityIndicatorView!
    private var notFindAPICompanyAleart:UIAlertController!
    private var notFindFireStoreCompanyAlert:UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        configTableView()
        configIndicator()
        configAleart()
        configFirestore()
    }
    
    private func configTableView(){
        tableView = UITableView(frame: view.bounds)
        tableView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight,
            .flexibleBottomMargin,
            .flexibleTopMargin]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            UINib(nibName: "TableViewCell", bundle: nil),
            forCellReuseIdentifier: "cell")
        tableView.bounces = true
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        view.addSubview(tableView)
    }
    
    private func configIndicator(){
        indicator = UIActivityIndicatorView()
        indicator.frame = view.bounds
        indicator.center = view.center
        indicator.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight,
            .flexibleBottomMargin,
            .flexibleTopMargin]
        indicator.style = UIActivityIndicatorView.Style.large
    }
    
    private func configAleart(){
        notFindAPICompanyAleart = UIAlertController(
            title: "見つかりませんでした",
            message: "該当する会社はありません。条件を変更して検索してください",
            preferredStyle: .alert)
        notFindAPICompanyAleart.addAction(UIAlertAction(title: "閉じる", style: .cancel))
        notFindFireStoreCompanyAlert = UIAlertController(
            title: "エラーが発生しました",
            message: "お手数ですが、通信状況を確認してもう一度行ってください",
            preferredStyle: .alert)
        notFindFireStoreCompanyAlert.addAction(UIAlertAction(title: "閉じる",style: .cancel))
    }
    
    private func configFirestore(){
        db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    func presentView(company:CompanyDataClass){
        indicator.stopAnimating()
        indicator.removeFromSuperview()
        delegate?.presentCompanyVC(company: company)
    }
    
    private func startIndicator() {
        view.addSubview(indicator)
        indicator.startAnimating()
    }
    
    private func stopIndicator() {
        indicator.stopAnimating()
        indicator.removeFromSuperview()
    }
    
    func search(searchBar: UISearchBar) {
        resultArray = []
        var searchText = ""
        var searchType:CompanySearchType! = nil
        if let intText = Int(searchBar.searchTextField.text!){
            searchText = String(intText)
            searchType = .sec_code
        }else{
            if searchBar.searchTextField.text! == ""{
                stopIndicator()
                return
            }
            searchText = searchBar.searchTextField.text!
                .applyingTransform(.fullwidthToHalfwidth, reverse: true)!
            searchType = .name_jp
        }
        Task{
            let companyRes = try? await companyFind(q: searchText, type: searchType)
            guard let companyList = companyRes?.results else{
                stopIndicator()
                present(notFindAPICompanyAleart, animated: true)
                return
            }
            if companyList.count == 0{
                stopIndicator()
                present(notFindAPICompanyAleart, animated: true)
                return
            }
            resultArray = companyList
            tableView.reloadData()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
        view.endEditing(true)
        startIndicator()
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
        guard let fav = realm.object(ofType: CategoryRealm.self, forPrimaryKey: "History") else {
            return
        }
        try! realm.write{
            if let index = fav.list.index(of: companyRealm!){
                fav.list.remove(at: index)
            }
            fav.list.insert(companyRealm!, at: 0)
            if fav.list.count > 20{
                fav.list.removeLast()
            }
        }
    }
    
    private func fetchCompany(company:ApiCompany){
        Task{
            do{
                let ref = db.collection("COMPANY_v2").document(company.jcn)
                let doc = try await FireStoreFetchDataClass().getDocument(ref: ref)
                guard let data = doc.data() else {
                    stopIndicator()
                    present(notFindAPICompanyAleart, animated: true)
                    return
                }
                let core = CompanyCoreDataClass(companyCoreDataDic: data)
                let company = try await FireStoreFetchDataClass().makeCompany_v2(for: core)
                presentView(company: company)
            }catch let err{
                stopIndicator()
                notFindFireStoreCompanyAlert.message = "お手数ですが、通信状況を確認してもう一度行ってください[\(err.localizedDescription)]"
                present(notFindFireStoreCompanyAlert, animated: true)
            }
        }
    }
}

extension SearchReslutsViewController: UISearchBarDelegate,UITextFieldDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(searchBar:searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
    }
    
}
extension SearchReslutsViewController:UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
    }
}
