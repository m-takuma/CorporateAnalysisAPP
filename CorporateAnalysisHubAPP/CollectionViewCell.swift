//
//  CollectionViewCell.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2022/02/03.
//

import UIKit
import Charts

class IndexCollectionViewCell: UICollectionViewCell {
    var indexNameLabel:UILabel!
    var indexValueLabel:UILabel!
    var stateImageView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLayout(){
        self.layer.cornerRadius = 8.0
        self.backgroundColor = .white
        indexNameLabel = UILabel(frame: CGRect(x: 8, y: 8, width: self.bounds.size.width - 16, height: (self.bounds.size.height - 24) * 4.5 / 10))
        
        let w_h = self.bounds.size.height - indexNameLabel.frame.size.height - 40
        stateImageView = UIImageView(frame: CGRect(x:self.bounds.size.width - w_h - 8, y: indexNameLabel.frame.maxY + 16, width: w_h, height: w_h))
        
        indexValueLabel = UILabel(frame:CGRect(x: 8, y: indexNameLabel.frame.maxY + 8, width: self.bounds.size.width - 24 - w_h, height: self.bounds.maxY - indexNameLabel.frame.maxY - 16))
        
        
        indexNameLabel.font = UIFont.systemFont(ofSize: indexNameLabel.bounds.size.height * 0.6, weight: .medium)
        indexValueLabel.font = UIFont.systemFont(ofSize: indexValueLabel.bounds.size.height * 0.6, weight: .medium)
        indexValueLabel.textAlignment = .right
        print(stateImageView.frame.size)
        stateImageView.image = UIImage(systemName: "exclamationmark.circle")//exclamationmark.circle//multiply.circle//checkmark.circle
        stateImageView.tintColor = .systemYellow
        self.addSubview(indexNameLabel)
        self.addSubview(indexValueLabel)
        self.addSubview(stateImageView)
        
    }
    
}

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var indexName: UILabel!
    @IBOutlet weak var indexValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createLayout()
        layer.cornerRadius = 8.0
        // Initialization code
    }
    func createLayout(){
        indexName.frame = CGRect(x: 8, y: 8, width: self.bounds.size.width - 16, height: (self.bounds.size.height - 24) * 3 / 10)
        indexValue.frame = CGRect(x: 8, y: indexName.frame.maxY + 8, width: self.bounds.size.width - 16, height: self.bounds.maxY - indexName.frame.maxY - 16)
        
    }

}

class ChartsCollectionViewCell: UICollectionViewCell {
    
    var title: UILabel!
    var chartView: BarChartView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLayout() {
        self.backgroundColor = .white
        layer.cornerRadius = 8.0
        title = UILabel(frame: CGRect(x: 8, y: 8, width: self.bounds.size.width - 16, height: self.bounds.size.height / 10))
        chartView = BarChartView(frame: CGRect(x: 8, y: title.frame.maxY + 8, width: self.bounds.size.width - 16, height: self.frame.size.height - title.frame.maxY - 16))
        
        title.font = UIFont.systemFont(ofSize: title.frame.size.height * 0.9,weight: .semibold)
        chartView.layer.cornerRadius = 8.0
        self.addSubview(title)
        self.addSubview(chartView)
    }
    
    
}
