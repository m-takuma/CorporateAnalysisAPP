//
//  NotLoadAdView.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/09/19.
//

import UIKit

class NotLoadAdView: UIView {
    var textLabel: UILabel!
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override required init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .originalWhite
        configView()
        configTextLabel()
    }
    
    private func configView() {
        self.tag = 100
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    private func configTextLabel() {
        textLabel = UILabel(frame: self.bounds)
        textLabel.text = "広告欄"
        textLabel.textAlignment = .center
        self.addSubview(textLabel)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
