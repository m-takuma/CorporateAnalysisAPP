//
//  TabBarController.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Takuma on 2021/12/24.
//

import UIKit
import SwiftUI

import GoogleMobileAds

class TabBarController: UITabBarController {
    private var bannerView:GADBannerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = true
        self.view.backgroundColor = .systemBackground
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemGroupedBackground
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
        //setUpTab()
        
        // Do any additional setup after loading the view.
    }
    private func setUpTab(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchVC") as! SearchViewController
        configBannerView()
        searchVC.tabBarItem = UITabBarItem(title: "検索", image: UIImage(systemName: "magnifyingglass"), tag: 0)
        viewControllers = [searchVC]
    }
    
    private func configBannerView(){
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = GoogleAdUnitID_Banner_Test
        
        bannerView.rootViewController = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
            
            ])
        bannerView.load(GADRequest())
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

class UpDateView:UIViewController{
    override func loadView() {
        super.loadView()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
    }
}
