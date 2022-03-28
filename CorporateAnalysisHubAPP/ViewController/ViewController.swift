//
//  ViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2021/12/11.
//

import UIKit
import Charts


class ViewController: UIViewController {
    class LeftAxisFormatter:NSObject, IAxisValueFormatter{
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let roundV = round(round(value / 100) * 100)
            let numFormatter = NumberFormatter()
            numFormatter.numberStyle = .decimal
            numFormatter.groupingSeparator = ","
            numFormatter.groupingSize = 3
            let result = numFormatter.string(from: NSNumber(value: roundV))
            return result!
        }
    }
    
    
    var company:CompanyDataClass!
    var temp = 0
    
    lazy var collectionView: UICollectionView = { () -> UICollectionView in
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemGroupedBackground
        
        
        collectionView.register(ChartsCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    lazy var tableView:UITableView = { () -> UITableView in
        let tableView = UITableView(frame: .zero,style:.insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemGroupedBackground
        let cell = UITableViewCell()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        return tableView
        
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        switch temp{
        case 0,1:
            self.view.addSubview(tableView)
        case 2,3,4:
            collectionView.collectionViewLayout = createLayout()
            self.view.addSubview(collectionView)
        default:
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        tableView.frame = view.bounds
        
    }
    
    
    func createLayout() -> UICollectionViewFlowLayout{
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        let cellWidth = (self.view.frame.size.width - 32)
        let cellHeight = cellWidth / 1.4142
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        
        return layout
        
    }

    
}



extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch temp{
        case 0:
            return 0
        case 1:
            return 0
        case 2:
            return 2
        case 3:
            return 4
        case 4:
            return 5
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChartsCollectionViewCell
        let barChartView = cell.chartView!
        cell.title.adjustsFontSizeToFitWidth = true
        let keys = { () -> Array<String> in
            var keys = self.company.finDataSort(type: 1)
            if keys.count > 5{
                keys.removeSubrange(5...(keys.count - 1))
            }
            keys.reverse()
            return keys
        }
        var years:Array<String> = []
        for i in 0 ..< keys().count{
            let calendar = Calendar(identifier: .gregorian)
            let date = company.finDataDict[keys()[i]]!.CurrentFiscalYearEndDate.dateValue()
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            years.append("\(year)/\(month)")
        }
        let dataSet = { () -> BarChartDataSet in
            let dataSet:BarChartDataSet!
            switch self.temp{
            case 2:
                dataSet = self.createBSChartData(indexPath: indexPath, cell: cell)
            case 3:
                dataSet = self.createPLChartData(indexPath: indexPath, cell: cell)
                dataSet.colors = [.systemBlue]
            case 4:
                dataSet = self.createCfChartData(indexPath: indexPath, cell: cell)
                dataSet.colors = [.systemBlue]
            default:
                dataSet = self.createPLChartData(indexPath: indexPath, cell: cell)
            }
            dataSet.drawValuesEnabled = false
            return dataSet
        }
        let data = BarChartData(dataSet: dataSet())
        barChartView.data = data
        barChartView.xAxis.labelCount = {() -> Int in
            if keys().count < 5{
                return keys().count
            }else{
                return 5
            }
        }()
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: years)
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.drawAxisLineEnabled = false
        barChartView.leftAxis.drawZeroLineEnabled = true
        barChartView.leftAxis.forceLabelsEnabled = false
        barChartView.leftAxis.valueFormatter = LeftAxisFormatter()
        
        barChartView.highlightPerTapEnabled = false
        barChartView.highlightFullBarEnabled = false
        barChartView.dragEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        
        barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        
        return cell
    }
    
    private func createBSChartData(indexPath:IndexPath,cell:ChartsCollectionViewCell) -> BarChartDataSet{
        let keys = { () -> Array<String> in
            var keys = self.company.finDataSort(type: 1)
            if keys.count > 5{
                keys.removeSubrange(5...(keys.count - 1))
            }
            keys.reverse()
            return keys
        }
        switch indexPath.row{
        case 0:
            cell.title.text = "資産"
            return createBsAssetsChartData(keys: keys())
        case 1:
            cell.title.text = "負債・純資産"
            return createBsLiabilitiesChartData(keys: keys())
        default:
            return createBsAssetsChartData(keys: keys())
        }
    }
    
    private func createBsAssetsChartData(keys:Array<String>) -> BarChartDataSet{
        let yVals = (0 ..< keys.count).map { (i) -> BarChartDataEntry in
            var assets = self.company.finDataDict[keys[i]]!.bs.assets
            var currentAssets = self.company.finDataDict[keys[i]]!.bs.currentAssets
            var nonCurrentAssets = self.company.finDataDict[keys[i]]!.bs.noncurrentAssets
            var otherAssets = 0
            guard let assets = assets else{
                assets = 0
                return BarChartDataEntry(x: Double(i), yValues: [0,0,0])
            }
            if currentAssets == nil || nonCurrentAssets == nil{
                if currentAssets == nil{
                    currentAssets = 0
                }
                if nonCurrentAssets == nil{
                    nonCurrentAssets = 0
                }
                otherAssets = assets - (currentAssets! + nonCurrentAssets!)
            }
            return BarChartDataEntry(x: Double(i), yValues: [Double(otherAssets)/1000000, Double(nonCurrentAssets!)/1000000, Double(currentAssets!)/1000000], icon: UIImage(named: "icon"))
        }
        
        let dataSet = BarChartDataSet(entries: yVals)
        dataSet.colors = [ChartColorTemplates.material()[0], ChartColorTemplates.material()[1], ChartColorTemplates.material()[2]]
        dataSet.drawIconsEnabled = false
        dataSet.label = "(百万円)"
        dataSet.stackLabels = ["その他資産", "固定資産", "流動資産"]
        
        return dataSet
    }
    
    private func createBsLiabilitiesChartData(keys:Array<String>) -> BarChartDataSet{
        let yVals = (0 ..< keys.count).map { (i) -> BarChartDataEntry in
            var liabilities = {() -> Double in
                if let temp = self.company.finDataDict[keys[i]]!.bs.liabilities{
                    return Double(temp)
                }else{
                    return 0
                }
            }
            let currentLiabilities = {() -> Double in
                if let temp = self.company.finDataDict[keys[i]]!.bs.currentLiabilities{
                    return Double(temp)
                }else{
                    return 0
                }
            }
            let nonCurrentLiabilities = {() -> Double in
                if let temp = self.company.finDataDict[keys[i]]!.bs.noncurrentLiabilities{
                    return Double(temp)
                }else{
                    return 0
                }
            }
            let netAssets = {() -> Double in
                if let temp = self.company.finDataDict[keys[i]]!.bs.netAssets{
                    return Double(temp)
                }else{
                    return 0
                }
            }
            let otherLiabilities = {() -> Double in
                if let assets = self.company.finDataDict[keys[i]]!.bs.assets{
                    let temp = Double(assets) - (currentLiabilities() + nonCurrentLiabilities() + netAssets())
                    return temp
                }else{
                    return 0
                }
            }
            return BarChartDataEntry(x: Double(i), yValues: [netAssets()/1000000, otherLiabilities()/1000000, nonCurrentLiabilities()/1000000,currentLiabilities()/1000000], icon: UIImage(named: "icon"))
        }
        
        let dataSet = BarChartDataSet(entries: yVals)
        dataSet.colors = [ChartColorTemplates.material()[0], ChartColorTemplates.material()[1], ChartColorTemplates.material()[2],ChartColorTemplates.material()[3]]
        dataSet.drawIconsEnabled = false
        dataSet.label = "(百万円)"
        dataSet.stackLabels = ["純資産", "その他負債", "固定負債","流動負債"]
        
        return dataSet
    }
    
    private func createPLChartData(indexPath:IndexPath,cell:ChartsCollectionViewCell) -> BarChartDataSet{
        var rawData:Array<Double> = []
        let keys = { () -> Array<String> in
            var keys = self.company.finDataSort(type: 1)
            if keys.count > 5{
                keys.removeSubrange(5...(keys.count - 1))
            }
            keys.reverse()
            return keys
        }
        switch indexPath.row{
        case 0:
            cell.title.text = "売上高"
            for i in 0 ..< keys().count{
                var data = company.finDataDict[keys()[i]]!.pl.netSales
                if data == nil{
                    data = 0
                }
                let data2:Double = (round(Double(data! / 1000000)))
                rawData.append(data2)
            }
        case 1:
            cell.title.text = "営業利益"
            
            for i in 0 ..< keys().count{
                var data = company.finDataDict[keys()[i]]!.pl.operatingIncome
                if data == nil{
                    data = 0
                }
                let data2:Double = Double(data! / 1000000)
                rawData.append(data2)
            }
        case 2:
            cell.title.text = "税引前当期純利益"

            
            for i in 0 ..< keys().count{
                var data = company.finDataDict[keys()[i]]!.pl.incomeBeforeIncomeTaxes
                if data == nil{
                    data = 0
                }
                let data2:Double = Double(data! / 1000000)
                rawData.append(data2)
            }
        case 3:
            cell.title.text = "親会社に帰属する当期純利益"
            
            for i in 0 ..< keys().count{
                var data = company.finDataDict[keys()[i]]!.pl.profitLossAttributableToOwnersOfParent
                if data == nil{
                    data = 0
                }
                let data2:Double = Double(data! / 1000000)
                rawData.append(data2)
            }
        default: break
        }
        let entries = (0 ..< keys().count).map { (i) -> BarChartDataEntry in
            return BarChartDataEntry(x: Double(i), y:Double(rawData[i]), icon: UIImage(named: "icon"))
        }
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.drawIconsEnabled = false
        dataSet.label = "(百万円)"
        if rawData.max()! < 0{
            cell.chartView.leftAxis.axisMaximum = 0
        }
        if rawData.min()! > 0{
            cell.chartView.leftAxis.axisMinimum = 0
        }
        return dataSet
    }
    
    private func createCfChartData(indexPath:IndexPath,cell:ChartsCollectionViewCell) -> BarChartDataSet{
        var rawData:Array<Double> = []
        let keys = { () -> Array<String> in
            var keys = self.company.finDataSort(type: 1)
            if keys.count > 5{
                keys.removeSubrange(5...(keys.count - 1))
            }
            keys.reverse()
            return keys
        }
        switch indexPath.row{
        case 0:
            cell.title.text = "営業活動によるキャッシュ・フロー"
            for i in 0 ..< keys().count{
                var data = company.finDataDict[keys()[i]]!.cf.netCashProvidedByUsedInOperatingActivities
                if data == nil{
                    data = 0
                }
                let data2:Double = Double(data! / 1000000)
                rawData.append(data2)
            }
        case 1:
            cell.title.text = "投資活動によるキャッシュ・フロー"
            for i in 0 ..< keys().count{
                var data = company.finDataDict[keys()[i]]!.cf.netCashProvidedByUsedInInvestmentActivities
                if data == nil{
                    data = 0
                }
                let data2:Double = Double(data! / 1000000)
                rawData.append(data2)
            }
        case 2:
            cell.title.text = "財務活動によるキャッシュフロー"
            for i in 0 ..< keys().count{
                var data = company.finDataDict[keys()[i]]!.cf.netCashProvidedByUsedInFinancingActivities
                if data == nil{
                    data = 0
                }
                let data2:Double = Double(data! / 1000000)
                rawData.append(data2)
            }
        case 3:
            cell.title.text = "現金及び現金同等物の増減額"
            for i in 0 ..< keys().count{
                var data = company.finDataDict[keys()[i]]!.cf.netIncreaseDecreaseInCashAndCashEquivalents
                if data == nil{
                    data = 0
                }
                let data2:Double = Double(data! / 1000000)
                rawData.append(data2)
            }
        case 4:
            cell.title.text = "現金及び現金同等物の期末残高"
            for i in 0 ..< keys().count{
                var data = company.finDataDict[keys()[i]]!.cf.cashAndCashEquivalents
                if data == nil{
                    data = 0
                }
                let data2:Double = Double(data! / 1000000)
                rawData.append(data2)
            }
            
        default:
            break
        }
        let entries = (0 ..< keys().count).map { (i) -> BarChartDataEntry in
            return BarChartDataEntry(x: Double(i), y:Double(rawData[i]), icon: UIImage(named: "icon"))
        }
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.drawIconsEnabled = false
        dataSet.label = "(百万円)"
        if rawData.max()! < 0{
            cell.chartView.leftAxis.axisMaximum = 0
        }
        if rawData.min()! > 0{
            cell.chartView.leftAxis.axisMinimum = 0
        }
        return dataSet
    
    
    
    }
        
    
}


extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch temp{
        case 0:
            return 8
        case 1:
            return 11
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = UIListContentConfiguration.valueCell()
        content.textProperties.adjustsFontSizeToFitWidth = true
        content.textProperties.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        content.secondaryTextProperties.adjustsFontSizeToFitWidth = false
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        content.secondaryTextProperties.color = .label
        content.prefersSideBySideTextAndSecondaryText = true
        switch temp{
        case 0:
            let result = createCompanyOverview(indexPath: indexPath)
            content.text = result.text
            content.secondaryText = result.secondary
        case 1:
            let result = createCompanyIndex(indexPath: indexPath)
            content.text = result.text
            content.secondaryText = result.secondary
        default:
            break
        }
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func createCompanyOverview(indexPath:IndexPath) -> (text:String?,secondary:String?){
        var text = ""
        var secondaryText = ""
        switch indexPath.row{
        case 0:
            text = "会社名"
            secondaryText = company.coreData.companyNameInJP
        case 1:
            text = "(英)会社名"
            secondaryText = company.coreData.companyNameInENG
        case 2:
            text = "EDINETコード"
            secondaryText = company.coreData.EDINETCode
        case 3:
            text = "証券コード"
            secondaryText = company.coreData.secCode
        case 4:
            text = "法人番号"
            secondaryText = company.coreData.JCN
        case 5:
            text = "会計基準"
            let key = company.finDataSort(type: 1)[0]
            secondaryText = company.finDataDict[key]!.AccountingStandard
        case 6:
            text = "決算月"
            let key = company.finDataSort(type: 1)[0]
            let calendar = Calendar(identifier: .gregorian)
            let month = calendar.component(.month, from: company.finDataDict[key]!.CurrentFiscalYearEndDate.dateValue())
            secondaryText = "\(month) 月"
        case 7:
            text = "保存データ最終更新日"
            let calendar = Calendar(identifier: .gregorian)
            let date = company.coreData.lastModified.dateValue()
            let year = calendar.component(.year , from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            secondaryText = "\(year) 年 \(month) 月 \(day) 日"
        default:
            break
        }
        return (text:text,secondary:secondaryText)
    }
    
    private func createCompanyIndex(indexPath:IndexPath) -> (text:String?,secondary:String?){
        let keys = { () -> Array<String> in
            var keys = self.company.finDataSort(type: 1)
            if keys.count > 5{
                keys.removeSubrange(5...(keys.count - 1))
            }
            keys.reverse()
            return keys
        }
        var text = ""
        var secondaryText = ""
        switch indexPath.row{
        case 0:
            text = "ROE"
            secondaryText = {() -> String in
                guard let index = company.finDataDict[keys().last!]!.finIndex.ROE else { return "N/A" }
                return "\(round(index * 10000) / 100) %"
            }()
        case 1:
            text = "ROA"
            secondaryText = {() -> String in
                guard let index = company.finDataDict[keys().last!]!.finIndex.ROA else { return "N/A" }
                return "\(round(index * 10000) / 100) %"
            }()
        case 2:
            text = "自己資本比率"
            secondaryText = {() -> String in
                guard let index = company.finDataDict[keys().last!]!.finIndex.equityRatio else { return "N/A" }
                return "\(round(index * 10000) / 100) %"
            }()
        case 3:
            text = "流動比率"
            secondaryText = {() -> String in
                guard let index = company.finDataDict[keys().last!]!.finIndex.currentRatio else { return "N/A" }
                return "\(round(index * 10000) / 100) %"
            }()
        case 4:
            text = "固定比率"
            secondaryText = {() -> String in
                guard let index = company.finDataDict[keys().last!]!.finIndex.fixedAssetsToNetWorth else { return "N/A" }
                return "\(round(index * 10000) / 100) %"
            }()
        case 5:
            text = "固定長期適合率"
            secondaryText = {() -> String in
                guard let index = company.finDataDict[keys().last!]!.finIndex.fixedAssetToFixedLiabilityRatio else { return "N/A" }
                return "\(round(index * 10000) / 100) %"
            }()
        case 6:
            text = "売上高営業利益率"
            secondaryText = {() -> String in
                guard let index = company.finDataDict[keys().last!]!.finIndex.operatingIncomeMargin else { return "N/A" }
                return "\(round(index * 10000) / 100) %"
            }()
        case 7:
            text = "売上高純利益率"
            secondaryText = {() -> String in
                guard let index = company.finDataDict[keys().last!]!.finIndex.netProfitAttributeOfOwnerMargin else { return "N/A" }
                return "\(round(index * 10000) / 100) %"
            }()
        case 8:
            text = "売上営業キャッシュ・フロー比率"
            secondaryText = {() -> String in
                guard let index = company.finDataDict[keys().last!]!.finIndex.netSalesOperatingCFRatio else { return "N/A" }
                return "\(round(index * 10000) / 100) %"
            }()
        case 9:
            text = "自己資本営業キャッシュ・フロー比率"
            secondaryText = {() -> String in
                guard let index = company.finDataDict[keys().last!]!.finIndex.equityOperatingCFRatio else { return "N/A" }
                return "\(round(index * 10000) / 100) %"
            }()
        case 10:
            text = "キャッシュ・フロー版当座比率"
            secondaryText = {() -> String in
                guard let index = company.finDataDict[keys().last!]!.finIndex.operatingCFCurrentLiabilitiesRatio else { return "N/A" }
                return "\(round(index * 10000) / 100) %"
            }()
        default:
            break
        }
        return (text:text,secondary:secondaryText)
    }

    
    
}

