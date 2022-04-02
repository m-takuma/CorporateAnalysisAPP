//
//  CollectionViewCell.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Takuma on 2022/02/03.
//

import UIKit
import Charts

class IndexCollectionViewCell: UICollectionViewCell {
    var indexNameLabel:UILabel!
    var indexValueLabel:UILabel!
    var stateImageView:UIImageView!
    var separatorView:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLayout(){
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 4.0
        self.backgroundColor = .originalWhite
        
        indexNameLabel = UILabel(frame: CGRect(x: 8, y: 8, width: self.bounds.size.width - 16, height: (self.bounds.size.height - 24) * 4.5 / 10))
        
        let w_h = self.bounds.size.height - indexNameLabel.frame.size.height - 40
        stateImageView = UIImageView(frame: CGRect(x:self.bounds.size.width - w_h - 8, y: indexNameLabel.frame.maxY + 16, width: w_h, height: w_h))
        
        indexValueLabel = UILabel(frame:CGRect(x: 8, y: indexNameLabel.frame.maxY + 8, width: self.bounds.size.width - 24 - w_h, height: self.bounds.maxY - indexNameLabel.frame.maxY - 16))
        
        separatorView = UIView(frame: CGRect(x: 8, y: indexNameLabel.frame.maxY + 4, width: self.frame.size.width - 8, height: 0.2))
        
        indexNameLabel.font = UIFont.systemFont(ofSize: indexNameLabel.bounds.size.height * 0.6, weight: .medium)
        indexValueLabel.font = UIFont.systemFont(ofSize: indexValueLabel.bounds.size.height * 0.6, weight: .medium)
        indexValueLabel.textAlignment = .right
        print(stateImageView.frame.size)
        stateImageView.image = UIImage(systemName: "exclamationmark.circle")//exclamationmark.circle//multiply.circle//checkmark.circle
        stateImageView.tintColor = .systemYellow
        separatorView.backgroundColor = .systemGray3
        self.addSubview(indexNameLabel)
        self.addSubview(indexValueLabel)
        self.addSubview(stateImageView)
        self.addSubview(separatorView)
        
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
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 4.0
        self.backgroundColor = .originalWhite
        self.layer.cornerRadius = 8.0
        title = UILabel(frame: CGRect(x: 8, y: 8, width: self.bounds.size.width - 16, height: self.bounds.size.height / 10))
        chartView = BarChartView(frame: CGRect(x: 8, y: title.frame.maxY + 8, width: self.bounds.size.width - 16, height: self.frame.size.height - title.frame.maxY - 16))
        title.font = UIFont.systemFont(ofSize: title.frame.size.height * 0.9,weight: .semibold)
        chartView.layer.cornerRadius = 8.0
        self.addSubview(title)
        self.addSubview(chartView)
    }
}

class ArticleCell: UICollectionViewCell {
    
    class var reuseIdentifier: String { "article-cell-reuse-identifier" }
    var indexNameLabel:UILabel!
    var indexValueLabel:UILabel!
    var stateImageView:UIImageView!
    var separatorView:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLayout(){
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 4.0
        self.backgroundColor = .originalWhite
        
        indexNameLabel = UILabel(frame: CGRect(x: 8, y: 8, width: self.bounds.size.width - 16, height: (self.bounds.size.height - 24) * 4.5 / 10))
        
        let w_h = self.bounds.size.height - indexNameLabel.frame.size.height - 40
        stateImageView = UIImageView(frame: CGRect(x:self.bounds.size.width - w_h - 8, y: indexNameLabel.frame.maxY + 16, width: w_h, height: w_h))
        
        indexValueLabel = UILabel(frame:CGRect(x: 8, y: indexNameLabel.frame.maxY + 8, width: self.bounds.size.width - 24 - w_h, height: self.bounds.maxY - indexNameLabel.frame.maxY - 16))
        
        separatorView = UIView(frame: CGRect(x: 8, y: indexNameLabel.frame.maxY + 4, width: self.frame.size.width - 8, height: 0.8))
        
        indexNameLabel.font = UIFont.systemFont(ofSize: indexNameLabel.bounds.size.height * 0.6, weight: .medium)
        indexValueLabel.font = UIFont.systemFont(ofSize: indexValueLabel.bounds.size.height * 0.6, weight: .medium)
        indexValueLabel.textAlignment = .right
        stateImageView.image = UIImage(systemName: "multiply.circle")//exclamationmark.circle//multiply.circle//checkmark.circle
        stateImageView.tintColor = .systemRed
        separatorView.backgroundColor = .separator
        
        indexNameLabel.adjustsFontSizeToFitWidth = true
        indexValueLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(indexNameLabel)
        self.addSubview(indexValueLabel)
        self.addSubview(stateImageView)
        self.addSubview(separatorView)
        
    }
}

class LargeArticleCell: UICollectionViewCell {
    
    class var reuseIdentifier: String { "large-article-cell-reuse-identifier" }
    
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
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 4.0
        self.backgroundColor = .originalWhite
        self.layer.cornerRadius = 8.0
        title = UILabel(frame: CGRect(x: 8, y: 8, width: self.bounds.size.width - 16, height: self.bounds.size.height / 8.5))
        title.adjustsFontSizeToFitWidth = true
        chartView = BarChartView(frame: CGRect(x: 8, y: title.frame.maxY + 8, width: self.bounds.size.width - 16, height: self.frame.size.height - title.frame.maxY - 16))
        
        title.font = UIFont.systemFont(ofSize: title.frame.size.height,weight: .semibold)
        chartView.layer.cornerRadius = 8.0
        self.addSubview(title)
        self.addSubview(chartView)
    }
}
class SectionView: UICollectionReusableView {
    
    static let reuseIdentifier = "section-supplementary-reuse-identifier"
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.frame = self.bounds
        label.font = .systemFont(ofSize: 32, weight: .bold)
        addSubview(label)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
