//
//  CompanyViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2021/12/25.
//

import UIKit
import Foundation
import Charts
import HMSegmentedControl


class CompanyViewController: UIViewController{
    lazy var segmentedControl_2 = {() -> UISegmentedControl in
        let segmentedControl = UISegmentedControl(items: ["概要データ","詳細データ"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], for: .highlighted)
        return segmentedControl
    }()
    
    lazy var segmentedControl = {() -> HMSegmentedControl in
        let segmentedControl = HMSegmentedControl(sectionTitles: ["概要データ","詳細データ"])
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.selectionIndicatorLocation = .bottom
        segmentedControl.selectionStyle = .fullWidthStripe
        if #available(iOS 15.0, *) {
            segmentedControl.selectionIndicatorColor = .systemCyan
        } else {
            // Fallback on earlier versions
        }
        segmentedControl.backgroundColor = .systemGroupedBackground
        segmentedControl.selectionIndicatorHeight = 4.0
        segmentedControl.selectedTitleTextAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16, weight: .medium)]
        segmentedControl.titleTextAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16, weight: .regular)]
        return segmentedControl
    }()
    

    
    var collectionView: UICollectionView!
    var ContainerView:UIView!
    

    
    //var outlineDataList:Array<CompanyFinIndexData.Tmp> = []
        
    
    var company:CompanyDataClass!
    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>! = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //outlineDataList = [.equityRatio,.ROA,.ROE,.ROIC,.shortTermLiquidity,.fixedAssetsToNetWorth,.grossProfitMargin,.operatingIncomeMargin]
        self.view.backgroundColor = .systemGroupedBackground
        let CompanyDetailViewController = CompanyDetailViewController()
        self.addChild(CompanyDetailViewController)
        self.ContainerView = CompanyDetailViewController.view
        
        //collectionViewの設定
        configureCollectionView()
        //cellの構造の設定をする
        configureDataSource()
        //データを作る
        applyInitialSnapshots()
        
        
        navigationItem.title = {() -> String in
            guard var name = company.coreData.simpleCompanyNameInJP else{
                return "企業名が取得できませんでした"
            }
            if name.count > 11{
                name = name.replacingOccurrences(of: "ホールディングス", with: "ＨＤ")
            }
            return name
        }()
        navigationItem.largeTitleDisplayMode = .never
        self.view.addSubview(segmentedControl)
        updateView(segmentIndex: Int(self.segmentedControl.selectedSegmentIndex), VC:CompanyDetailViewController)
        
        // Do any additional setup after loading the view.
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentedControl.frame = CGRect(x: 0, y: navigationController!.navigationBar.frame.maxY, width: self.view.frame.size.width, height: 40)
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            collectionView.frame = CGRect(x: 0, y: self.segmentedControl.frame.maxY, width: self.view.frame.width , height: self.view.frame.height - (self.tabBarController?.tabBar.frame.height)! - self.segmentedControl.frame.maxY)
        case 1:
            ContainerView.frame = CGRect(x: 0, y: self.segmentedControl.frame.maxY, width: self.view.frame.width , height: self.view.frame.height - (self.tabBarController?.tabBar.frame.height)! - self.segmentedControl.frame.maxY)
        default:
            print("Error")
        }
        
    }
    
    private func updateView(segmentIndex:Int,VC:UIViewController){
        switch segmentIndex{
        case 0:
            self.ContainerView.removeFromSuperview()
            self.view.addSubview(collectionView)
        case 1:
            self.collectionView.removeFromSuperview()
            self.view.addSubview(ContainerView)
            VC.didMove(toParent: self)
        default:
            print("Error")
        }
    }
    


}

class CompanyDetailViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{
    var company:CompanyDataClass!
    
    override func loadView() {
        super.loadView()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = self.view.bounds
        self.view.addSubview(tableView)
    }
    
    lazy var tableView:UITableView = { () -> UITableView in
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        return tableView
        
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 18
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.textLabel?.text = "項目"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25, weight: .regular)
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .disclosureIndicator
        
        
        switch indexPath.row{
        case 0:
            //企業概要
            cell.textLabel?.text = "企業概要"
        case 1:
            //各種財務指標
            cell.textLabel?.text = "各種財務指標"
        case 2:
            //BS
            cell.textLabel?.text = "財務"
        case 3:
            //PL
            cell.textLabel?.text = "業績"
        case 4:
            //CF
            cell.textLabel?.text = "キャッシュフロー"
        case 5:
            //沿革
            cell.textLabel?.text = "沿革"
        case 6:
            //事業の内容
            cell.textLabel?.text = "事業の内容"
        case 7:
            cell.textLabel?.text = "関係会社の状況"
        case 8:
            cell.textLabel?.text = "従業員の状況"
        case 9:
            cell.textLabel?.text = "経営方針"
        case 10:
            cell.textLabel?.text = "事業のリスク"
        case 11:
            cell.textLabel?.text = "経営者による分析"
        case 12:
            cell.textLabel?.text = "研究開発活動"
        case 13:
            cell.textLabel?.text = "設備投資"
        case 14:
            cell.textLabel?.text = "配当方針"
        case 15:
            cell.textLabel?.text = "貸借対照表"
        case 16:
            cell.textLabel?.text = "損益計算書"
        case 17:
            cell.textLabel?.text = "キャッシュ・フロー計算書"
            
        default:
            print("Error")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "VC") as! ViewController
        VC.company = self.company
        VC.temp = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
}

extension CompanyViewController:UICollectionViewDelegate{
    class LeftAxisFormatter:NSObject, IAxisValueFormatter{
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let numFormatter = NumberFormatter()
            numFormatter.numberStyle = .decimal
            numFormatter.groupingSeparator = ","
            numFormatter.groupingSize = 3
            if value > 100000{
                let roundV = round(round(value / 10) * 10)
                let result = numFormatter.string(from: NSNumber(value: roundV))
                return result!
            }
            let result = numFormatter.string(from: NSNumber(value: value))
            return result!
        }
    }

    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: configureCollectionViewLayout())
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        
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
                let w = self.view.frame.size.width - 32
                let h = w / 1.618
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(w), heightDimension: .absolute(h))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(w), heightDimension: .absolute(h))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 8
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
                let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .estimated(44))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: "header", alignment: .topLeading)
                section.boundarySupplementaryItems = [sectionHeader]
            case .Important,.Safety,.Profitability,.Efficiency:
                let w = (self.view.frame.size.width - 40) / 2
                let h = w / 1.618
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(w), heightDimension: .absolute(h))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(w), heightDimension: .absolute(h * 2 + 8))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 2)
                group.interItemSpacing = NSCollectionLayoutSpacing.fixed(8)
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 8
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
                let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .estimated(44))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: "header", alignment: .topLeading)
                section.boundarySupplementaryItems = [sectionHeader]
            }
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func configureDataSource(){
        dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>.init(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, item in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }
            switch section {
            case .Transition:
                let cell = self.createTransitionCell(collectionView: collectionView, indexPath: indexPath, item: item)
                return cell
            case .Important,.Safety,.Profitability,.Efficiency:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCell.reuseIdentifier, for: indexPath) as! ArticleCell
                let item_enc = item as! IndexDataItem
                cell.indexNameLabel.text = item_enc.name
                cell.indexValueLabel.text = item_enc.index
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
        
        
        let item = TransitionItem(company: self.company, type: .EPS)
        let item_1 = TransitionItem(company: self.company, type: .BPS)
        let item_2 = TransitionItem(company: self.company, type: .Revenue)
        let item_3 = TransitionItem(company: self.company, type: .OperatingIncome)
        
        let recentItems = [item,item_1,item_2,item_3]
        var recentsSnapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
        recentsSnapshot.append(recentItems)
        dataSource.apply(recentsSnapshot, to: .Transition, animatingDifferences: false)
        
        let item1 = IndexDataItem(company:self.company, value: .ROE)
        let item2 = IndexDataItem(company:self.company, value: .ROA)
        let item3 = IndexDataItem(company:self.company, value: .equityRatio)
        let item4 = IndexDataItem(company:self.company, value: .ROIC)
        let item5 = IndexDataItem(company:self.company, value: .fixedAssetsToNetWorth)
        let item6 = IndexDataItem(company:self.company, value: .operatingIncomeMargin)
        var allSnapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
        let recentItems_2 = [item1,item2,item3,item4,item5,item6]
        allSnapshot.append(recentItems_2)
        dataSource.apply(allSnapshot, to: .Important, animatingDifferences: false)
    }
}





extension CompanyViewController{
    private enum Section:Int,Hashable,CaseIterable,CustomStringConvertible{
        case Transition
        case Important
        case Safety
        case Profitability
        case Efficiency
        
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
        static func == (lhs: CompanyViewController.TransitionItem, rhs: CompanyViewController.TransitionItem) -> Bool {
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
        let value:CompanyFinIndexData.Tmp
        let name:String
        let index:String
        
        init(company:CompanyDataClass,value:CompanyFinIndexData.Tmp){
            self.value = value
            self.name = value.rawValue
            let key = {() -> String in
                return company.finDataSort(type: 1)[0]
            }()
            let data = company.finDataDict[key]!.finIndex!
            do {
                let value = try data.fetchIndexData(tag: value)
                self.index = "\(String(format: "%.2f", value)) %".replacingOccurrences(of: "-", with: "- ")
            } catch  {
                self.index = "N/A %"//.applyingTransform(.fullwidthToHalfwidth, reverse: true)!
            }
        }
    }
}

