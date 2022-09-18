//
//  CompanyViewSwiftUI.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Takuma on 2022/03/17.
//

import SwiftUI
import UIKit
import RealmSwift
import FirebaseFirestore

class FavViewController:UIViewController{
    var model = FavViewModel()
    
    
    lazy var indicator = {() -> UIActivityIndicatorView in
        let indicator = UIActivityIndicatorView()
        indicator.frame = view.bounds
        indicator.center = view.center
        indicator.style = UIActivityIndicatorView.Style.large
        return indicator
    }()
    
    lazy var notFetchCompanyDataAlert = {() -> UIAlertController in
        let alert = UIAlertController(title: "エラーが発生しました", message: "お手数ですが、通信状況を確認してもう一度行ってください", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
        return alert
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationItem()
        view.backgroundColor = .systemGroupedBackground
        guard model.fav.count != 0 else{
            return configWhenNoneFav()
        }
        let fav = model.fav.first
        guard let fav = fav else{
            return configWhenNoneFav()
        }
        configFavView(fav: fav)
    }
    
    private func configWhenNoneFav(){
        let label = UILabel()
        label.text = "予期しないエラーが発生しました"
        label.font = UIFont.systemFont(ofSize: 44, weight: .bold)
        label.textColor = .tertiaryLabel
        label.frame.size = CGSize(width: view.frame.width / 3, height: 44)
        label.center = view.center
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        view.addSubview(label)
    }
    
    private func startIndicator(vc:UIViewController) {
        vc.view.addSubview(indicator)
        indicator.startAnimating()
    }
    
    private func stopIndicator() {
        indicator.stopAnimating()
        indicator.removeFromSuperview()
    }
    
    private func presentCompanyViewController(vc:UIViewController, company: CompanyRealm) {
        let db = Firestore.firestore()
        startIndicator(vc: vc)
        db.collection("COMPANY_v2").document(company.jcn!).getDocument{ doc, err in
            guard let doc = doc else {
                self.stopIndicator()
                self.present(self.notFetchCompanyDataAlert, animated: true)
                return
            }
            Task{
                do{
                    guard let data = doc.data() else {
                        throw NSError()
                    }
                    let coreData = CompanyCoreDataClass(companyCoreDataDic: data)
                    let company = try await FireStoreFetchDataClass().makeCompany_v2(for: coreData)
                    let companyRootVC = CompanyRootViewController()
                    companyRootVC.company = company
                    self.stopIndicator()
                    self.navigationController?.pushViewController(companyRootVC, animated: true)
                }catch{
                    self.stopIndicator()
                    self.present(self.notFetchCompanyDataAlert, animated: true)
                }
            }
        }
    }
    
    
    private func configFavView(fav:CategoryRealm){
        let favSwiftUIView = FavSwiftUIView(model: fav)
        let vc = UIHostingController(rootView: favSwiftUIView)
        addChild(vc)
        vc.rootView.present = {(_ company:CompanyRealm) -> Void in
            self.presentCompanyViewController(vc: vc, company: company)
        }
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            vc.view.heightAnchor.constraint(equalTo: view.heightAnchor),
            vc.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            vc.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configNavigationItem(){
        navigationItem.title = "お気に入り"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
}
