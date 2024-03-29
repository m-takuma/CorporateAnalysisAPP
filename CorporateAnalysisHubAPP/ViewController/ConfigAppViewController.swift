//
//  ConfigAppViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Takuma on 2022/03/22.
//

import UIKit
import RealmSwift
import FirebaseFirestore
import FirebaseDatabase
import Foundation
import Combine
import SafariServices
import FirebaseAuth

@available(iOS 15.0, *)
class ConfigAppViewController: UIViewController {
    let rdbFetchClass = RealtimeDBFetchClass()
    let secCode_ls = secCodeList()

    lazy var progressView = {() -> UIProgressView in
        let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 32, height: 44))
        progressView.center = self.view.center
        progressView.backgroundColor = .systemGroupedBackground
        progressView.progressViewStyle = .default
        return progressView
    }()

    lazy var button = {() -> UIButton in
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 70)
        button.setTitle("もう一度行う", for: .normal)
        button.layer.cornerRadius = 10.0
        button.center = self.view.center
        button.backgroundColor = .systemCyan
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }()

    lazy var indicator = {() -> UIActivityIndicatorView in
        let indicator = UIActivityIndicatorView(frame: self.view.bounds)
        indicator.center = self.view.center
        indicator.style = UIActivityIndicatorView.Style.large
        return indicator
    }()

    // private var realm:Realm!

    var counter = 0

    // var currentProgress = CurrentValueSubject<Double,Never>(0)

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        // self.view.addSubview(button)
        self.view.addSubview(indicator)
        indicator.startAnimating()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*let cancelable = currentProgress.sink { current in
            self.progressView.setProgress(Float(current), animated: true)
            print(current)
        }*/
        doRealmMigration()
        guard let realm = try? Realm() else { return }
        downloadCompanySearchIndex()

        if realm.object(ofType: CategoryRealm.self, forPrimaryKey: "History") == nil {
            let category = CategoryRealm(id: "History", name: "履歴", list: [])
            try? realm.write { realm.add(category) }
        }
        if realm.object(ofType: CategoryRealm.self, forPrimaryKey: "FAV") == nil {
            let category = CategoryRealm(id: "FAV", name: "お気に入り", list: [])
            try? realm.write { realm.add(category) }
        }
    }
    @objc func buttonTapped(_ sender: UIButton) {
        self.retry()
    }
    private func retry() {
        self.button.removeFromSuperview()
        self.view.addSubview(indicator)
        indicator.startAnimating()
        Task {
            self.downloadCompanySearchIndex()
        }
    }

    private func doRealmMigration() {
        let nextSchemaVersion = 0
        let config = Realm.Configuration(
            schemaVersion: UInt64(nextSchemaVersion),
            migrationBlock: { migration, oldSchemaVersion in
                print(oldSchemaVersion)
                print(migration)
                if oldSchemaVersion < nextSchemaVersion {
                }
        })
        Realm.Configuration.defaultConfiguration = config
    }

    private func downloadCompanySearchIndex() {
        Task {
            do {
                _ = try await AuthSignIn.sigInAnoymously()
                let ref = Database.database().reference().child("SearchIndex").child("main")
                let data = try await rdbFetchClass.getData(ref: ref)
                guard let dict = data.value! as? [String: [String: Any]] else { return }
                downloadSearchIndexInRealm(dataDict: dict)
            } catch {
                let aleart = UIAlertController(title: "エラーが発生しました", message: "初期データをダウンロードします。お手数ですが、通信状況を確認してもう一度行ってください", preferredStyle: .alert)
                let retry = UIAlertAction(title: "もう一度試す", style: .default) { (_: UIAlertAction) in
                    self.retry()
                    self.counter += 1
                    print("再試行")
                }
                aleart.addAction(retry)
                if self.counter > 1 {
                    let contact = UIAlertAction(title: "お問い合わせ", style: .default) { (_: UIAlertAction) in
                        self.counter = 0
                        let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSdG97LVQrPmRKL7Sr1HbyRFHbOqs0rTsT4JTA2zPFl-HyXFDg/viewform?usp=sf_link")
                        let safariVC = SFSafariViewController(url: url!)
                        safariVC.modalPresentationStyle = .overFullScreen
                        self.present(safariVC, animated: true, completion: nil)
                        self.view.addSubview(self.button)
                        print("お問い合わせ")
                    }
                    aleart.addAction(contact)
                }
                self.indicator.stopAnimating()
                indicator.removeFromSuperview()
                self.present(aleart, animated: true, completion: nil)
            }
        }
    }
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "label name")
    private func downloadSearchIndexInRealm(dataDict: [String: [String: Any]]) {
        for key in dataDict.keys {
            dispatchGroup.enter()
            dispatchQueue.async(group: dispatchGroup) {
                guard let realm = try? Realm() else { return }
                if let company = realm.object(ofType: CompanyRealm.self, forPrimaryKey: key) {
                    if company.simpleCompanyName == (dataDict[key]?["companyName"] as? String) && company.secCode == (dataDict[key]?["secCode"] as? String) {
                    } else {
                        try? realm.write {
                            company.secCode = (dataDict[key]?["secCode"] as? String)
                            company.simpleCompanyName = (dataDict[key]?["companyName"] as? String)
                        }
                    }
                } else {
                    let co = CompanyRealm(jcn: key, secCode: dataDict[key]?["secCode"] as? String, simpleName: (dataDict[key]?["companyName"] as? String)!)
                    try? realm.write {
                        realm.add(co, update: .modified)
                    }
                }
                self.dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.createCategoryRealm()
            let ud = UserDefaults.standard
            ud.set(true, forKey: userState.isFirstBoot.rawValue)
            ud.set(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, forKey: userState.appVersion.rawValue)
            print("終わった")
            self.indicator.stopAnimating()
            self.indicator.removeFromSuperview()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TabVC")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
        }
    }

    private func createCategoryRealm() {
        createN225Category()
        createCore30Category()
    }
    private func createN225Category() {
        guard let realm = try? Realm() else { return }
        var N225co: [CompanyRealm] = []
        for secCode in secCode_ls.n225 {
            let company = realm.objects(CompanyRealm.self).filter("secCode == '\(secCode)'")
            if company.isEmpty {
                print(secCode)
            } else {
                N225co.append(company[0])
            }
        }
        let n225 = realm.object(ofType: CategoryRealm.self, forPrimaryKey: "N225")
        if let n225 = n225 {
            try? realm.write {
                realm.delete(n225)
            }
        }
        let category = CategoryRealm(id: "N225", name: "N225", list: N225co)
        try? realm.write {
            realm.add(category, update: .modified)
        }
    }
    private func createCore30Category() {
        guard let realm = try? Realm() else { return }
        var Core30co: [CompanyRealm] = []
        for secCode in secCode_ls.core30 {
            let company = realm.objects(CompanyRealm.self).filter("secCode == '\(secCode)'")
            if company.isEmpty {
                print(secCode)
            } else {
                Core30co.append(company[0])
            }
        }
        let core30 = realm.object(ofType: CategoryRealm.self, forPrimaryKey: "Core30")
        if let core30 = core30 {
            try? realm.write {
                realm.delete(core30)
            }
        }
        let category = CategoryRealm(id: "Core30", name: "Core30", list: Core30co)
        try? realm.write {
            realm.add(category, update: .modified)
        }
    }
}
