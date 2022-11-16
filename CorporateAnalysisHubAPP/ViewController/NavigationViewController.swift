//
//  NavigationViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Takuma on 2021/12/24.
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemGroupedBackground
        appearance.shadowColor = .clear
        navigationBar.isTranslucent = true
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        // Do any additional setup after loading the view.
    }
}
