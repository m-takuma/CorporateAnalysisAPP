//
//  CompanyRootViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/09/18.
//

import UIKit
import XLPagerTabStrip
import Foundation
import Charts
import Combine
import RealmSwift
import GoogleMobileAds



class CompanyRootTestViewController: BaseButtonBarPagerTabStripViewController<UpperTabCollectionViewCell> {
    
    
    var company:CompanyDataClass!
    var token:NotificationToken? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        self.buttonBarItemSpec = .nibFile(nibName: "UpperTabCollectionViewCell", bundle: Bundle(for: UpperTabCollectionViewCell.self), width: { _ in
            return UIScreen.main.bounds.size.width / 4
        })
        settings.style.selectedBarBackgroundColor = .systemCyan
        // ボタンとボタンの間の感覚
        settings.style.buttonBarMinimumLineSpacing = 0
        //左右のインセット
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
    }
    override func configure(cell: UpperTabCollectionViewCell, for indicatorInfo: IndicatorInfo) {
        cell.label.text = indicatorInfo.title?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    override func loadView() {
        super.loadView()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavItem()
        view.backgroundColor = .systemBackground
        buttonBarView.translatesAutoresizingMaskIntoConstraints = false
        buttonBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        buttonBarView.heightAnchor.constraint(equalToConstant: buttonBarView.frame.height).isActive = true
        buttonBarView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        buttonBarView.backgroundColor = .systemGroupedBackground
    }
    
    private func configNavItem(){
        navigationItem.title = {() -> String in
            guard var name = company.coreData.simpleCompanyNameInJP else{
                return "企業名が取得できませんでした"
            }
            if name.count > 11{
                name = name.replacingOccurrences(of: "ホールディングス", with: "ＨＤ")
            }
            return name
        }()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(), style: .plain, target: self, action: #selector(addBarButtonTapped(_:)))
        let realm = try! Realm()
        let fav = realm.object(ofType: CategoryRealm.self, forPrimaryKey: "FAV")!.list
        self.token = fav.observe({ (change:RealmCollectionChange) in
            let isAddFav = fav.contains { company in
                if company.jcn == self.company.coreData.JCN{
                    return true
                }else{
                    return false
                }
            }
            self.navigationItem.rightBarButtonItem!.image = (isAddFav ? UIImage(systemName: "star.fill"):UIImage(systemName: "star"))
        })
    }
    
    @objc func addBarButtonTapped(_ sender: UIBarButtonItem){
        let realm = try! Realm()
        let co = realm.object(ofType: CompanyRealm.self, forPrimaryKey: self.company.coreData.JCN)!
        let fav = realm.object(ofType: CategoryRealm.self, forPrimaryKey: "FAV")!.list
        if let index = fav.firstIndex(of: co){
            try! realm.write {
                fav.remove(at: index)
            }
        }else{
            try! realm.write{
                fav.append(co)
            }
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let outline = CompanyOutlineViewController(company: company)
        return [
            outline,
            CompanyDetailViewController(company: company)
        ]
    }

}
