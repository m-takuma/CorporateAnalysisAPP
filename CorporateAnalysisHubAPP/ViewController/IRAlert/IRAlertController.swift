//
//  IRAlertController.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/10/09.
//

import UIKit

final class IRAlertController: UIViewController {
    private var alertView = IRAlertView()
    private var allowActionButtonTouchEvent = true
    private var allowAutoDismiss = true

    convenience init(title: String, message: String? = nil) {
        self.init(nibName: nil, bundle: nil)
        alertView = IRAlertView(UIScreen.main.bounds, title: title, message: message)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = UIScreen.main.bounds
        view.addSubview(alertView)
    }
    
    func setAllowAutoDismiss(_ flag: Bool) {
        allowAutoDismiss = flag
    }

    func addAction(_ action: IRAlertAction) {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.cornerStyle = .dynamic
        var title = AttributedString.init(action.title)
        switch action.style {
        case .primary:
            config = UIButton.Configuration.filled()
            title.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        case .secondary:
            config = UIButton.Configuration.plain()
            config.background.strokeColor = config.baseForegroundColor
            config.background.strokeWidth = 1.0
            title.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        case .text:
            config = UIButton.Configuration.plain()
            title.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        }
        config.attributedTitle = title
        button.configuration = config
        let buttonAction = UIAction { _ in
            if self.allowAutoDismiss {
                self.dismiss(animated: true) {
                    action.handler?()
                    self.allowActionButtonTouchEvent = false
                }
            } else {
                action.handler?()
                self.allowActionButtonTouchEvent = false
            }
        }
        button.addAction(buttonAction, for: .touchUpInside)
        alertView.addButton(button)
    }
}
