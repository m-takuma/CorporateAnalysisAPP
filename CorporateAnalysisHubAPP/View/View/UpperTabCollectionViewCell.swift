//
//  UpperTabCollectionViewCell.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/09/18.
//

import UIKit

class UpperTabCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        label.frame = self.bounds
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        // Initialization code
    }

}
