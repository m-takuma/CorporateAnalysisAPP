//
//  CompanyViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2021/12/25.
//

import UIKit
import Foundation


class CompanyViewController: UIViewController{
    
    

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    lazy var collectionView: UICollectionView = { () -> UICollectionView in
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
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
        collectionView.collectionViewLayout = createLayout()
        
        navigationItem.title = {() -> String in
           var name = company.coreData.CorporateJPNName.replacingOccurrences(of: "株式会社", with: "")
            if name.count > 11{
                name = name.replacingOccurrences(of: "ホールディングス", with: "ＨＤ")
                name = name.applyingTransform(.fullwidthToHalfwidth, reverse: false)!
            }
            return name
        }()
        
        navigationItem.largeTitleDisplayMode = .never
        
        
        segmentedControl.backgroundColor = .gray
        
        
        
        updateView(segmentIndex: self.segmentedControl.selectedSegmentIndex)
        
        // Do any additional setup after loading the view.
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
    
    @IBAction func segmentedSwitch(_ sender: UISegmentedControl) {
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
        /*
        var tmp:[String:Date] = [:]
        for key in company.finDataDict.keys{
            tmp[key] = company.finDataDict[key]?.CurrentPeriodEndDate.dateValue()
        }
        let max = tmp.max { a, b in
            a.value < b.value
        }*/
        let indexData = company.finDataDict[company.finDataSort(type: 1)[0]]?.finIndex
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        var tmp:[String:Date] = [:]
        for key in company.finDataDict.keys{
            tmp[key] = company.finDataDict[key]?.CurrentPeriodEndDate.dateValue()
        }
        if tmp.count == 0{
            
        }else if tmp.count == 1{
            let keys = [String](tmp.keys)
            let indexData = company.finDataDict[keys[0]]?.finIndex
            cell.indexValue.adjustsFontSizeToFitWidth = true
            switch indexPath.row{
            case 0:
                cell.indexName.text = "自己資本比率"
                //cell.indexValue.text = "\(round(indexData!.capitalAdequacyRatio! * 10000) / 100) %"
            case 1:
                cell.indexName.text = "ROA"
                //cell.indexValue.text = "\(round(indexData!.ROA! * 10000) / 100) %"
            case 2:
                cell.indexName.text = "ROE"
                //cell.indexValue.text = "\(round(indexData!.ROE! * 10000) / 100) %"
            default:
                break
            }
        }else{
            let max = tmp.max { a, b in
                a.value < b.value
            }
            let indexData = company.finDataDict[max!.key]?.finIndex
            cell.indexValue.adjustsFontSizeToFitWidth = true
            switch indexPath.row{
            case 0:
                cell.indexName.text = "自己資本比率"
                //cell.indexValue.text = "\(round(indexData!.capitalAdequacyRatio! * 10000) / 100) %"
            case 1:
                cell.indexName.text = "ROA"
                //cell.indexValue.text = "\(round(indexData!.ROA! * 10000) / 100) %"
            case 2:
                cell.indexName.text = "ROE"
                //cell.indexValue.text = "\(round(indexData!.ROE! * 10000) / 100) %"
            default:
                break
            }
        }
        
        cell.backgroundColor = .lightGray
        return cell
    }
    
    
    
    func createLayout() -> UICollectionViewFlowLayout{
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        let cellWidthAndHeight = (self.view.frame.size.width - 48) / 2
        layout.itemSize = CGSize(width: cellWidthAndHeight, height: cellWidthAndHeight)
        
        return layout
        
    }
    
}

extension CompanyViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.textLabel?.text = "項目"
        
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.view.frame.size.height / 7
    }
    
    
    
}
