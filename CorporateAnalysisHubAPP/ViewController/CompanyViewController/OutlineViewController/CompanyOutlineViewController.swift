//
//  CompanyViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Takuma on 2021/12/25.
//

import UIKit
import Foundation
import Charts
import HMSegmentedControl
import Combine
import RealmSwift
import GoogleMobileAds
import XLPagerTabStrip
class CompanyOutlineViewController: UIViewController, IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "概要データ")
    }
    var company:CompanyDataClass!

    var collectionView: UICollectionView!
    
    var bannerView:GADBannerView!
    
    //var outlineDataList:Array<CompanyFinIndexData.Tmp> = []

    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>! = nil
    override func loadView() {
        super.loadView()
    }
    
    init(company:CompanyDataClass) {
        super.init(nibName: nil, bundle: nil)
        self.company = company
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //outlineDataList = [.equityRatio,.ROA,.ROE,.ROIC,.shortTermLiquidity,.fixedAssetsToNetWorth,.grossProfitMargin,.operatingIncomeMargin]
        self.view.backgroundColor = .systemGroupedBackground
        
        //collectionViewの設定
        configureCollectionView()
        //cellの構造の設定をする
        configureDataSource()
        //データを作る
        applyInitialSnapshots()
        // Admob設定
        configBannerView()
    }
    
    override func viewWillLayoutSubviews() {
        configAutoLayout()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: configureCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 50, right: 0)
        collectionView.register(ArticleCell.self, forCellWithReuseIdentifier: ArticleCell.reuseIdentifier)
        collectionView.register(LargeArticleCell.self, forCellWithReuseIdentifier: LargeArticleCell.reuseIdentifier)
        collectionView.register(SectionView.self, forSupplementaryViewOfKind: "header",
                                withReuseIdentifier: SectionView.reuseIdentifier)
        self.view.addSubview(collectionView)
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout{
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            var section: NSCollectionLayoutSection! = nil
            switch sectionKind {
            case .Transition:
                section = self.configTransitionSection()
            case .Important,.Safety,.Profitability,.Efficiency,.CFAnalysis:
                section = self.configNotTransitionSection()
            }
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func configTransitionSection() -> NSCollectionLayoutSection {
        let w = self.view.frame.size.width - 32
        let h = w / 1.618
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(w), heightDimension: .absolute(h))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(w), heightDimension: .absolute(h))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: "header", alignment: .topLeading)
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    private func configNotTransitionSection() -> NSCollectionLayoutSection {
        let w = (self.view.frame.size.width - 40) / 2
        let h = w / 1.618
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(w), heightDimension: .absolute(h))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(w), heightDimension: .absolute(h * 2 + 8))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(8)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: "header", alignment: .topLeading)
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    private func configBannerView(){
        bannerView = GADBannerView()
        bannerView.adUnitID = GoogleAdUnitID_Banner
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(view.frame.width)
        bannerView.rootViewController = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        bannerView.delegate = self
        bannerView.load(GADRequest())
    }
    
    private func configAutoLayout() {
        let buttomBunner = view.superview?.superview?.subviews.first { view in
            view is ButtonBarView
        }
        collectionView.widthAnchor.constraint(
            equalTo: view.widthAnchor
        ).isActive = true
        collectionView.topAnchor.constraint(
            equalTo: buttomBunner!.bottomAnchor
        ).isActive = true
        collectionView.bottomAnchor.constraint(
            equalTo: bannerView.topAnchor
        ).isActive = true
        bannerView.centerXAnchor.constraint(
            equalTo: view.centerXAnchor
        ).isActive = true
        bannerView.bottomAnchor.constraint(
            equalTo: tabBarController?.tabBar.topAnchor ?? view.safeAreaLayoutGuide.bottomAnchor
        ).isActive = true
    }
    
    
}
extension CompanyOutlineViewController:UICollectionViewDelegate{
    
    private func configureDataSource(){
        dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>.init(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, item in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }
            switch section {
            case .Transition:
                let cell = self.createTransitionCell(collectionView: collectionView, indexPath: indexPath, item: item)
                return cell
            case .Important,.Safety,.Profitability,.Efficiency,.CFAnalysis:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCell.reuseIdentifier, for: indexPath) as! ArticleCell
                let item_enc = item as! IndexDataItem
                cell.indexNameLabel.text = item_enc.name
                cell.indexValueLabel.text = item_enc.index
                if item_enc.status{
                    cell.stateImageView.image = UIImage(systemName: "checkmark.circle")
                    cell.stateImageView.tintColor = .systemGreen
                }else{
                    cell.stateImageView.image = UIImage(systemName: "multiply.circle")
                    cell.stateImageView.tintColor = .systemRed
                }
                return cell
            }
        })
        dataSource.supplementaryViewProvider = { [weak self]
        (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let self = self, let dataSource = self.dataSource else { return nil }
            
            let sectionHeader = collectionView.dequeueReusableSupplementaryView( ofKind: kind,
            withReuseIdentifier: SectionView.reuseIdentifier,
            for: indexPath) as! SectionView
            
            if #available(iOS 15.0, *) {
                let section = dataSource.sectionIdentifier(for: indexPath.section)
                sectionHeader.label.text = String(describing: section!)
            } else {
                sectionHeader.label.text = "読み込みエラー"
                // Fallback on earlier versions
            }
            
            return sectionHeader
        }
    }
    
    func createTransitionCell(collectionView:UICollectionView,indexPath:IndexPath,item:AnyHashable) -> LargeArticleCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LargeArticleCell.reuseIdentifier, for: indexPath) as! LargeArticleCell
        let item_enc = item as! TransitionItem
        cell.title.text = item_enc.name()
        let valueData = item_enc.data()
        let data = BarChartData(dataSet: valueData.0)
        cell.chartView.data = data
        cell.chartView.xAxis.labelCount = {() -> Int in
            if item_enc.keys.count < 5{
                return item_enc.keys.count
            }else{
                return 5
            }
        }()
        self.barChartsConfig(barChartView: cell.chartView, rawData: valueData.1, years: item_enc.years())
        return cell
    }
    func barChartsConfig(barChartView:BarChartView,rawData:Array<Double>,years:Array<String>){
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: years)
        barChartView.leftAxis.valueFormatter = LeftAxisFormatter()
        
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.drawAxisLineEnabled = false
        barChartView.leftAxis.drawZeroLineEnabled = true
        barChartView.leftAxis.forceLabelsEnabled = false
        
        barChartView.highlightPerTapEnabled = false
        barChartView.highlightFullBarEnabled = false
        barChartView.dragEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        
        if rawData.max()! < 0{
            barChartView.leftAxis.axisMaximum = 0
        }
        if rawData.min()! > 0{
            barChartView.leftAxis.axisMinimum = 0
        }
        
        barChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
    }
    
    func applyInitialSnapshots() {
        let sections = [Section.Transition,Section.Important]
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        
        let item = TransitionItem(company: self.company, type: .Revenue)
        let item_1 = TransitionItem(company: self.company, type: .OperatingIncome)
        let item_2 = TransitionItem(company: self.company, type: .EPS)
        let item_3 = TransitionItem(company: self.company, type: .BPS)
        
        let transitionItems = [item,item_1,item_2,item_3]
        
        let important_type:Array<CompanyFinIndexData.Tag> = [.ROE,.ROIC,.ROA,.equityRatio]
        let safety_type:Array<CompanyFinIndexData.Tag> = [.currentRatio,.shortTermLiquidity,.fixedAssetsToNetWorth,.fixedAssetToFixedLiabilityRatio,.debtEquityRatio,.netDebtEquityRation,.dependedDebtRatio]
        let profitability_type:Array<CompanyFinIndexData.Tag> = [.grossProfitMargin,.operatingIncomeMargin,.ordinaryIncomeMargin,.netProfitMargin,.netProfitAttributeOfOwnerMargin]
        let efficiency_type:Array<CompanyFinIndexData.Tag> = [.totalAssetsTurnover,.receivablesTurnover,.inventoryTurnover,.payableTurnover,.tangibleFixedAssetTurnover,.CCC]
        let cfAnalysis_type:Array<CompanyFinIndexData.Tag> = [.netSalesOperatingCFRatio,.equityOperatingCFRatio,.operatingCFCurrentLiabilitiesRatio,.operatingCFDebtRatio,.fixedInvestmentOperatingCFRatio]
        var important_items:Array<IndexDataItem> = []
        var safety_items:Array<IndexDataItem> = []
        var profitability_items:Array<IndexDataItem> = []
        var efficiency_items:Array<IndexDataItem> = []
        var cfAnalysis_items:Array<IndexDataItem> = []
        for type in CompanyFinIndexData.Tag.allCases{
            if important_type.contains(type){
                important_items.append(IndexDataItem(company: self.company, value: type))
            }else if safety_type.contains(type){
                safety_items.append(IndexDataItem(company: self.company, value: type))
            }else if profitability_type.contains(type){
                profitability_items.append(IndexDataItem(company: self.company, value: type))
            }else if efficiency_type.contains(type){
                efficiency_items.append(IndexDataItem(company: self.company, value: type))
            }else if cfAnalysis_type.contains(type){
                cfAnalysis_items.append(IndexDataItem(company: self.company, value: type))
            }
        }
        
        for section in Section.allCases{
            var snapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
            switch section{
            case .Transition:
                snapshot.append(transitionItems)
            case .Important:
                snapshot.append(important_items)
            case .Safety:
                snapshot.append(safety_items)
            case .Profitability:
                snapshot.append(profitability_items)
            case .Efficiency:
                snapshot.append(efficiency_items)
            case .CFAnalysis:
                snapshot.append(cfAnalysis_items)
            }
            dataSource.apply(snapshot, to: section, animatingDifferences: false)
        }
    }
}

extension CompanyOutlineViewController{
    private enum Section:Int,Hashable,CaseIterable,CustomStringConvertible{
        case Transition
        case Important
        case Safety
        case Profitability
        case Efficiency
        case CFAnalysis
        
        var description: String {
            switch self {
            case .Transition:
                return "推移"
            case .Important:
                return "重要指標"
            case .Safety:
                return "安全性"
            case .Profitability:
                return "収益性"
            case .Efficiency:
                return "効率性"
            case .CFAnalysis:
                return "CF分析"
            }
        }
    }
    
    private enum TransitionItemValueType:Int,Hashable,CaseIterable,CustomStringConvertible{
        case Revenue
        case OperatingIncome
        case EPS
        case BPS
        
        var description: String {
            switch self {
            case .Revenue:
                return "収益"
            case .OperatingIncome:
                return "営業利益"
            case .EPS:
                return "EPS"
            case .BPS:
                return "BPS"
            }
        }
    }
    
    private struct TransitionItem:Hashable{
        static func == (lhs: CompanyOutlineViewController.TransitionItem, rhs: CompanyOutlineViewController.TransitionItem) -> Bool {
            lhs.identifier == rhs.identifier
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        private let identifier = UUID()
        let company:CompanyDataClass
        let keys:Array<String>
        let type: TransitionItemValueType
        

        
        func years() -> Array<String>{
            var years:Array<String> = []
            for i in 0 ..< self.keys.count{
                let calendar = Calendar(identifier: .gregorian)
                let date = self.company.finDataDict[keys[i]]!.CurrentFiscalYearEndDate.dateValue()
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                years.append("\(year)/\(month)")
            }
            return years
        }
        func name() -> String{
            switch type {
            case .Revenue:
                let key = keys.last!
                let data_tuple = company.finDataDict[key]!.pl.getNetSales_etcValue()
                return data_tuple.1.rawValue
            case .OperatingIncome:
                let key = keys.last!
                let data_tuple = company.finDataDict[key]!.pl.getOperatingIncome()
                return data_tuple.1.rawValue
            case .EPS,.BPS:
                return String(describing: type)
            }
        }
        func data() -> (BarChartDataSet,Array<Double>){
            var rawData:Array<Double> = []
            switch type {
            case .Revenue:
                for i in 0 ..< keys.count{
                    let data = company.finDataDict[keys[i]]!.pl.getNetSales_etcValue()
                    let data2:Double = Double(data.0 / 1000000)
                    rawData.append(data2)
                }
            case .OperatingIncome:
                for i in 0 ..< keys.count{
                    let data = company.finDataDict[keys[i]]!.pl.getOperatingIncome()
                    let data2:Double = Double(data.0 / 1000000)
                    rawData.append(data2)
                }
            case .EPS:
                for i in 0 ..< keys.count{
                    var data = company.finDataDict[keys[i]]!.pl.EPS
                    if data == nil{ data = 0 }
                    rawData.append(data!)
                }
            case .BPS:
                for i in 0 ..< keys.count{
                    var data = company.finDataDict[keys[i]]!.bs.BPS
                    if data == nil{ data = 0 }
                    rawData.append(data!)
                }
            }
            let entries = (0 ..< keys.count).map { (i) -> BarChartDataEntry in
                return BarChartDataEntry(x: Double(i), y:rawData[i], icon: UIImage(named: "icon"))
            }
            let dataSet = BarChartDataSet(entries: entries)
            dataSet.drawIconsEnabled = false
            if type != .EPS && type != .BPS{
                dataSet.label = "(百万円)"
            }else{
                dataSet.label = "(円)"
            }
            dataSet.colors = [.systemBlue]
            dataSet.drawValuesEnabled = false
            return (dataSet,rawData)
        }
        
        init(company:CompanyDataClass,type:TransitionItemValueType){
            self.company = company
            self.keys = {() -> Array<String> in
                var keys = company.finDataSort(type: 1)
                if keys.count > 5{
                    keys.removeSubrange(5...(keys.count - 1))
                }
                keys.reverse()
                return keys
            }()
            self.type = type
        }
        
    }
    private struct IndexDataItem:Hashable{
        private let identifier = UUID()
        let value:CompanyFinIndexData.Tag
        let name:String
        let index:String
        let status:Bool
        
        init(company:CompanyDataClass,value:CompanyFinIndexData.Tag){
            self.value = value
            self.name = value.rawValue
            
            let unit = {() -> String in
                switch value{
                case
                        .receivablesTurnover,
                        .inventoryTurnover,
                        .payableTurnover,
                        .CCC:
                   return "日"
                case
                        .totalAssetsTurnover,
                        .tangibleFixedAssetTurnover:
                    return "回"
                case .operatingCFDebtRatio:
                    return "倍"
                default:
                    return "%"
                }
            }()
            let key = {() -> String in
                return company.finDataSort(type: 1)[0]
            }()
            let data = company.finDataDict[key]!.finIndex!
            do {
                let value = try data.fetchIndexData(tag: value)
                self.index = "\(String(format: "%.2f", value)) \(unit)".replacingOccurrences(of: "-", with: "- ")
                self.status = true
            } catch  {
                self.index = "N/A \(unit)"
                self.status = false
            }
        }
    }
}

extension CompanyOutlineViewController: GADBannerViewDelegate{
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1) {
            bannerView.alpha = 1
        }
    }
}
