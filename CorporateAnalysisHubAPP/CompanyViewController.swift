//
//  CompanyViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2021/12/25.
//

import UIKit
import Foundation


class CompanyViewController: UIViewController{
    lazy var segmentedControl = {() -> UISegmentedControl in
        let segmentedControl = UISegmentedControl(items: ["概要データ","詳細データ"])
        segmentedControl.addTarget(self, action: #selector(self.segmentedSwitch(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], for: .highlighted)
        return segmentedControl
    }()
    

    
    lazy var collectionView: UICollectionView = { () -> UICollectionView in
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        //collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView.register(IndexCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    lazy var tableView:UITableView = { () -> UITableView in
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        return tableView
        
    }()
    
        
    
    var company:CompanyDataClass!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemGroupedBackground
        collectionView.collectionViewLayout = createLayout()
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
        updateView(segmentIndex: self.segmentedControl.selectedSegmentIndex)
        
        // Do any additional setup after loading the view.
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentedControl.frame = CGRect(x: 16, y: navigationController!.navigationBar.frame.maxY + 16, width: self.view.frame.size.width - 32, height: 32)
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            collectionView.frame = CGRect(x: 0, y: self.segmentedControl.frame.maxY, width: self.view.frame.width , height: self.view.frame.height - (self.tabBarController?.tabBar.frame.height)! - self.segmentedControl.frame.maxY)
        case 1:
            tableView.frame = CGRect(x: 0, y: self.segmentedControl.frame.maxY, width: self.view.frame.width , height: self.view.frame.height - (self.tabBarController?.tabBar.frame.height)! - self.segmentedControl.frame.maxY)
        default:
            print("Error")
        }
        
    }
    
    private func updateView(segmentIndex:Int){
        switch segmentIndex{
        case 0:
            self.tableView.removeFromSuperview()
            self.view.addSubview(collectionView)
        case 1:
            self.collectionView.removeFromSuperview()
            self.view.addSubview(tableView)
        default:
            print("Error")
        }
    }
    
    @objc func segmentedSwitch(_ sender: UISegmentedControl) {
        updateView(segmentIndex: sender.selectedSegmentIndex)
    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CompanyViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! IndexCollectionViewCell
        
        var tmp:[String:Date] = [:]
        for key in company.finDataDict.keys{
            tmp[key] = company.finDataDict[key]?.CurrentPeriodEndDate.dateValue()
        }
        var indexData:CompanyFinIndexData!
        if tmp.count == 0{
            return cell
        }else if tmp.count == 1{
            let keys = [String](tmp.keys)
            indexData = company.finDataDict[keys[0]]?.finIndex
        }else{
            let max = tmp.max { a, b in
                a.value < b.value
            }
            indexData = company.finDataDict[max!.key]?.finIndex
        }
        var value:CompanyFinIndexData.Tmp! = nil
        switch indexPath.row{
        case 0:
            value = .equityRatio
        case 1:
            value = .equityRatio
        case 2:
            value = .equityRatio
        default:
            cell.indexNameLabel.text = "エラーが発生"
            cell.indexValueLabel.text = "N/A".applyingTransform(.fullwidthToHalfwidth, reverse: true)
            return cell
        }
        do {
            cell.indexNameLabel.text = value.rawValue
            let value = try indexData.fetchIndexData(tag: value)
            cell.indexValueLabel.text = "\(value) %".replacingOccurrences(of: "-", with: "△ ")
        } catch  {
            cell.indexNameLabel.text = value.rawValue
            cell.indexValueLabel.text = "N/A".applyingTransform(.fullwidthToHalfwidth, reverse: true)
        }
        return cell
    }
    
    
    
    func createLayout() -> UICollectionViewFlowLayout{
        collectionView.backgroundColor = .systemGroupedBackground
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        let cellWidthAndHeight = (self.view.frame.size.width - 48) / 2
        layout.itemSize = CGSize(width: cellWidthAndHeight, height: cellWidthAndHeight / 1.618)
        
        return layout
        
    }
    
}

extension CompanyViewController:UITableViewDelegate,UITableViewDataSource{
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
