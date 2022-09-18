//
//  CompanyDetailViewCompany.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/09/18.
//

import Foundation
import UIKit
import XLPagerTabStrip
import GoogleMobileAds
class CompanyDetailViewController:UIViewController,UITableViewDelegate,UITableViewDataSource, IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Test1")
    }
    var company:CompanyDataClass!
    var bannerView:GADBannerView!
    
    override func loadView() {
        super.loadView()
    }
    
    init(company:CompanyDataClass) {
        super.init(nibName: nil, bundle: nil)
        self.company = company
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = self.view.bounds
        self.view.addSubview(tableView)
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = GoogleAdUnitID_Banner
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Task{
            try await AuthSignInClass().sigInAnoymously()
        }
    }
    private func addBannerViewToView(_ bannerView: GADBannerView){
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
            
            ])
    }
    
    lazy var tableView:UITableView = { () -> UITableView in
        let tableView = UITableView(frame: .zero,style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        return tableView
        
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "項目"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .disclosureIndicator
        
        
        switch indexPath.row{
        case 0:
            //企業概要
            cell.textLabel?.text = "企業概要"
        case 1:
            //各種財務指標
            cell.textLabel?.text = "各種財務指標"
        case 2:
            //BS
            cell.textLabel?.text = "財務"
        case 3:
            //PL
            cell.textLabel?.text = "業績"
        case 4:
            //CF
            cell.textLabel?.text = "キャッシュフロー"
        default:
            print("Error")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "VC") as! ViewController
        VC.company = self.company
        VC.title = cell?.textLabel?.text
        VC.temp = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(VC, animated: true)
    }
}

