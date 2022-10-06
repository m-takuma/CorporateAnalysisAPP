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
class CompanyDetailOutlineViewController:UIViewController, IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "詳細データ")
    }
    
    var company:CompanyDataClass!
    var outlineTableView: UITableView!
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
        view.backgroundColor = .systemGroupedBackground
        configTableView()
        configBannerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task{
            try await AuthSignIn.sigInAnoymously()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configAutoLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func configTableView() {
        outlineTableView = UITableView(frame: view.bounds, style: .insetGrouped)
        outlineTableView.delegate = self
        outlineTableView.dataSource = self
        outlineTableView.backgroundColor = .systemGroupedBackground
        outlineTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        outlineTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(outlineTableView)
    }
    
    private func configBannerView() {
        bannerView = GADBannerView()
        bannerView.delegate = self
        bannerView.load(GADRequest())
        bannerView.adUnitID = GoogleAdUnitID_Banner
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(view.frame.width)
        bannerView.rootViewController = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
    }
    
    private func configAutoLayout() {
        let buttomBunner = view.superview?.superview?.subviews.first { view in
            view is ButtonBarView
        }
        outlineTableView.widthAnchor.constraint(
            equalTo: view.widthAnchor
        ).isActive = true
        outlineTableView.topAnchor.constraint(
            equalTo: buttomBunner!.bottomAnchor
        ).isActive = true
        outlineTableView.bottomAnchor.constraint(
            equalTo: bannerView.topAnchor
        ).isActive = true
        bannerView.centerXAnchor.constraint(
            equalTo: view.centerXAnchor
        ).isActive = true
        bannerView.bottomAnchor.constraint(
            equalTo: tabBarController?.tabBar.topAnchor ?? view.safeAreaLayoutGuide.bottomAnchor
        ).isActive = true
    }
}

extension CompanyDetailOutlineViewController: UITableViewDelegate,UITableViewDataSource {
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
        let VC = CompanyDetailViewController(company: company, temp: indexPath.row)
        VC.title = cell?.textLabel?.text
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(VC, animated: true)
    }
}

extension CompanyDetailOutlineViewController: GADBannerViewDelegate{
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        if let errorView = bannerView.subviews.first(where: { view in
            view is NotLoadAdView
        }){
            errorView.removeFromSuperview()
        }
        bannerView.alpha = 0
        UIView.animate(withDuration: 1) {
            bannerView.alpha = 1
        }
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        guard bannerView.subviews.contains(where: { view in
            view is NotLoadAdView
        }) else {
            let errorView = NotLoadAdView(frame: bannerView.bounds)
            bannerView.addSubview(errorView)
            return
        }
    }
}

