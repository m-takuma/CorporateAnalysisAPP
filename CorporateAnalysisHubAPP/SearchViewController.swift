//
//  SearchViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2021/12/12.
//

import UIKit
import FirebaseFirestore

class SearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UITextFieldDelegate {
    
    
    var db:Firestore!
    var resultArray:Array<CompanyCoreDataClass> = []
    var ref: DocumentReference? = nil
    
    var indicator = UIActivityIndicatorView()
    let aleart = UIAlertController(title: "見つかりませんでした", message: "該当する会社はありません。条件を変更して検索してください", preferredStyle: .alert)
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "検索"
        navigationController?.navigationBar.prefersLargeTitles = true
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        aleart.addAction(UIAlertAction(title: "閉じる", style: .default))
        indicator.center = view.center
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = .black
        view.addSubview(indicator)
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.bounces = false
        resultsTableView.keyboardDismissMode = .onDrag
        resultsTableView.showsVerticalScrollIndicator = false
        resultsTableView.showsHorizontalScrollIndicator = false
        
        searchBar.delegate = self
        searchBar.searchTextField.delegate = self
        resultsTableView.keyboardDismissMode = .onDrag

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        resultsTableView.frame = CGRect(x: 0, y: searchBar.frame.maxY, width: self.view.frame.width , height: self.view.frame.height - (self.tabBarController?.tabBar.frame.height)! - searchBar.frame.maxY)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let company = resultArray[indexPath.row]
        cell.textLabel?.text = company.CorporateJPNName!
        cell.detailTextLabel?.text = company.SecCode
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        indicator.startAnimating()
        self.resultArray = []
        if Int(searchBar.searchTextField.text!) != nil{
            let searchText = searchBar.searchTextField.text! + "0"
            db.collection("Company").whereField("SecCode", isEqualTo: searchText).getDocuments() { querySnapshot, err in
                if let err = err {
                    print("Error getting documents:\(err)")
                }else{
                    if querySnapshot!.documents.count == 0{
                        self.present(self.aleart, animated: true, completion: nil)
                    }
                    for document in querySnapshot!.documents{
                        let companyCoreData = CompanyCoreDataClass.init(companyCoreDataDic: document.data())
                        self.resultArray.append(companyCoreData)
                        self.resultsTableView.reloadData()
                    }
                }
                self.indicator.stopAnimating()
            }
        }else{
            if searchBar.searchTextField.text! == ""{
                return
            }
            let searchText_1 = searchBar.searchTextField.text!.applyingTransform(.fullwidthToHalfwidth, reverse: true)! + "株式会社"
            let searchText_2 = "株式会社" + searchBar.searchTextField.text!.applyingTransform(.fullwidthToHalfwidth, reverse: true)!
            db.collection("Company").whereField("CorporateJPNName",in: [searchText_1,searchText_2]).getDocuments(){ querySnapshot, err in
                if let err = err {
                    print("Error getting documents:\(err)")
                }else{
                    if querySnapshot!.documents.count == 0{
                        self.present(self.aleart, animated: true, completion: nil)
                    }
                    for document in querySnapshot!.documents{
                        let companyCoreData = CompanyCoreDataClass.init(companyCoreDataDic: document.data())
                        self.resultArray.append(companyCoreData)
                        self.resultsTableView.reloadData()
                    }
                }
            }
            self.indicator.stopAnimating()
        }
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coreData = resultArray[indexPath.row]
        try? makeCompany(coreData: coreData)
    }
    
    func makeCompany(coreData:CompanyCoreDataClass) throws{
        guard let JCN = coreData.JCN else{
            throw CustomError.NoneJCN
        }
        let docRef = db.collection("Company").document("\(JCN)").collection("FinDocument")
        //財務諸表ドキュメント一覧を取得する
        docRef.getDocuments { (querySnapshot, err) in
            if let err = err{
            }else{
                let company = CompanyDataClass.init(coreData: coreData)
                var finDataDict:[String:CompanyFinData] = [:]
                var dataCountDict:[String:Int] = [:]
                var documentCount = 0
                for document in querySnapshot!.documents{
                    let companyFindata = CompanyFinData.init(companyFinData: document.data())
                    finDataDict["\(document.documentID)"] = companyFindata
                    dataCountDict["\(document.documentID)"] = 0
                    //bs
                    docRef.document("\(document.documentID)").collection("DetailData").document("BSCoreData").getDocument{(doc,err1) in
                        let bs = CompanyBSCoreData.init(bs: doc!.data()!, accountStandard: finDataDict["\(document.documentID)"]!.AccountingStandard)
                        
                        let findata = finDataDict["\(document.documentID)"]!
                        findata.bs = bs
                        finDataDict["\(document.documentID)"]! = findata
                        
                        dataCountDict["\(document.documentID)"]! = dataCountDict["\(document.documentID)"]! + 1
                        if dataCountDict["\(document.documentID)"]! == 5{
                            documentCount += 1
                            if documentCount == querySnapshot?.count{
                                company.finDataDict = finDataDict
                                self.presentView(company: company)
                            }
                        }
                        
                    }
                    //pl
                    docRef.document("\(document.documentID)").collection("DetailData").document("PLCoreData").getDocument{(doc,err1) in
                        let pl = CompanyPLCoreData.init(pl: doc!.data()!, accountingStandard: finDataDict["\(document.documentID)"]!.AccountingStandard)
                        companyFindata.pl = pl
                        let findata = finDataDict["\(document.documentID)"]!
                        findata.pl = pl
                        finDataDict["\(document.documentID)"]! = findata
                        
                        dataCountDict["\(document.documentID)"]! = dataCountDict["\(document.documentID)"]! + 1
                        if dataCountDict["\(document.documentID)"]! == 5{
                            documentCount += 1
                            if documentCount == querySnapshot?.count{
                                company.finDataDict = finDataDict
                                self.presentView(company: company)
                            }
                        }
                        
                    }
                    //cf
                    docRef.document("\(document.documentID)").collection("DetailData").document("CFCoreData").getDocument{(doc,err1) in
                        let cf = CompanyCFCoreData.init(cf: doc!.data()!, accountStandard: finDataDict["\(document.documentID)"]!.AccountingStandard)

                        let findata = finDataDict["\(document.documentID)"]!
                        findata.cf = cf
                        finDataDict["\(document.documentID)"]! = findata
                        
                        dataCountDict["\(document.documentID)"]! = dataCountDict["\(document.documentID)"]! + 1
                        if dataCountDict["\(document.documentID)"]! == 5{
                            documentCount += 1
                            if documentCount == querySnapshot?.count{
                                company.finDataDict = finDataDict
                                self.presentView(company: company)
                            }
                        }
                        
                    }
                    //other
                    docRef.document("\(document.documentID)").collection("DetailData").document("OtherData").getDocument{(doc,err1) in
                        let other = CompanyOhterData.init(other: doc!.data()!)
                        let findata = finDataDict["\(document.documentID)"]!
                        findata.other = other
                        finDataDict["\(document.documentID)"]! = findata
                        
                        dataCountDict["\(document.documentID)"]! = dataCountDict["\(document.documentID)"]! + 1
                        if dataCountDict["\(document.documentID)"]! == 5{
                            documentCount += 1
                            if documentCount == querySnapshot?.count{
                                company.finDataDict = finDataDict
                                self.presentView(company: company)
                            }
                        }
                        
                        
                    }
                    //index
                    docRef.document("\(document.documentID)").collection("DetailData").document("FinIndex").getDocument{(doc,err1) in
                        let indexData = CompanyFinIndexData.init(indexData: doc!.data()!)
                        let findata = finDataDict["\(document.documentID)"]!
                        findata.finIndex = indexData
                        finDataDict["\(document.documentID)"]! = findata
                        
                        dataCountDict["\(document.documentID)"]! = dataCountDict["\(document.documentID)"]! + 1
                        if dataCountDict["\(document.documentID)"]! == 5{
                            documentCount += 1
                            if documentCount == querySnapshot?.count{
                                company.finDataDict = finDataDict
                                self.presentView(company: company)
                            }
                        }
                        
                    }

                    
                }
            }
        }
        //ドキュメントIDと各財務諸表の基礎データを結びつける
        //詳細データを取得する
    }
    
    func presentView(company:CompanyDataClass){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let CompanyVC = storyboard.instantiateViewController(withIdentifier: "CompanyVC") as! CompanyViewController
        CompanyVC.company = company
        self.navigationController?.pushViewController(CompanyVC, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
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
