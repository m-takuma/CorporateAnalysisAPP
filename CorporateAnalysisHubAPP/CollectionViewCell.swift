//
//  CollectionViewCell.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2022/02/03.
//

import UIKit
import Charts

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var indexName: UILabel!
    @IBOutlet weak var indexValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 8.0
        // Initialization code
    }

}

class ChartsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var ChartView: BarChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
