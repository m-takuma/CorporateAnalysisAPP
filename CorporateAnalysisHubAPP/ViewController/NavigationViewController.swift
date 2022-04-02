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
        self.view.backgroundColor = .systemBackground
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemGroupedBackground
        appearance.shadowColor = .clear
        navigationBar.isTranslucent = true
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance

        // Do any additional setup after loading the view.
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
