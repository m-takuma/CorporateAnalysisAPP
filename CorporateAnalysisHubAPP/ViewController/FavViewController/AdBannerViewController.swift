//
//  AdBannerViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/09/18.
//

import UIKit
import SwiftUI
import GoogleMobileAds

class BannerAdVC: UIViewController {
    
    var bannerView: GADBannerView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerView = GADBannerView()
        bannerView.rootViewController = self
        view.addSubview(bannerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBannerAd()
    }
    
    // 画面回転を検知するメソッド
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            // 回転開始時に行う
            self.bannerView.isHidden = true //So banner doesn't disappear in middle of animation
        } completion: { _ in
            // 回転終了時に行う
            self.bannerView.isHidden = false
            self.loadBannerAd()
        }
    }
    
    func loadBannerAd() {
        let frame = view.frame.inset(by: view.safeAreaInsets)
        let viewWidth = frame.size.width
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView.adUnitID = GoogleAdUnitID_Banner
        bannerView.load(GADRequest())
    }
    
}


struct BannerAd: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return BannerAdVC()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}