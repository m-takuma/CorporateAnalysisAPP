//
//  IRAlertView.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/10/09.
//

import UIKit

class IRAlertView: UIView {
    private(set) var baseView = UIStackView()
    private(set) var textBaseView = UIStackView()
    private(set) var buttonBaseView = UIStackView()
    private(set) var titleLabel = UILabel()
    private(set) var messageLabel = UILabel()
    
    convenience init(_ frame: CGRect, title: String, message: String?) {
        self.init(frame: frame)
        backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.4)
        setupBaseView()
        setupTextBaseView(title: title, message: message)
        setupButtonBaseView()
    }
    
    private func setupBaseView() {
        addSubview(baseView)
        baseView.axis = .vertical
        baseView.distribution = .fill
        baseView.spacing = 28
        baseView.backgroundColor = .originalWhite
        baseView.layer.cornerRadius = 12
        baseView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        baseView.isLayoutMarginsRelativeArrangement = true
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.widthAnchor.constraint(equalTo: widthAnchor, constant: -40).isActive = true
        baseView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        baseView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    private func setupTextBaseView(title: String, message: String?) {
        textBaseView.axis = .vertical
        textBaseView.spacing = 12
        textBaseView.alignment = .center
        baseView.addArrangedSubview(textBaseView)
        setupTitleLabel(title)
        setupMessageLabel(message)
    }
    private func setupTitleLabel(_ title: String) {
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        textBaseView.addArrangedSubview(titleLabel)
    }
    
    private func setupMessageLabel(_ message: String?) {
        guard let message = message else { return }
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.sizeToFit()
        textBaseView.addArrangedSubview(messageLabel)
    }
    
    private func setupButtonBaseView() {
        baseView.addArrangedSubview(buttonBaseView)
        buttonBaseView.axis = .vertical
        buttonBaseView.spacing = 6
        buttonBaseView.alignment = .fill
        buttonBaseView.distribution = .fill
    }
    func addButton(_ button: UIButton) {
        buttonBaseView.addArrangedSubview(button)
    }
}

struct IRAlertAction {
    var title: String
    var style: IRAlertAction.Style
    var handler: (() -> Void)?
    init(title: String, style: IRAlertAction.Style, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

extension IRAlertAction {
    enum Style {
        case primary, secondary, text
    }
}
