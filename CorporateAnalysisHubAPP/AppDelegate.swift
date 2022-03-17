//
//  AppDelegate.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2021/12/11.
//

import UIKit
import Firebase
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var db:Firestore!
    let n225 = [1332,1333,1605,1721,1801,1802,1803,1808,1812,1925,1928,1963,2002,2269,2282,2413,2432,2501,2502,2503,2531,2768,2801,2802,2871,2914,3086,3099,3101,3103,3289,3382,3401,3402,3405,3407,3436,3659,3861,3863,4004,4005,4021,4042,4043,4061,4063,4151,4183,4188,4208,4324,4452,4502,4503,4506,4507,4519,4523,4543,4568,4578,4631,4689,4704,4751,4755,4901,4902,4911,5019,5020,5101,5108,5201,5202,5214,5232,5233,5301,5332,5333,5401,5406,5411,5541,5631,5703,5706,5707,5711,5713,5714,5801,5802,5803,6098,6103,6113,6178,6301,6302,6305,6326,6361,6367,6471,6472,6473,6479,6501,6503,6504,6506,6645,6674,6701,6702,6703,6724,6752,6753,6758,6762,6770,6841,6857,6861,6902,6952,6954,6971,6976,6981,6988,7003,7004,7011,7012,7013,7186,7201,7202,7203,7205,7211,7261,7267,7269,7270,7272,7731,7733,7735,7751,7752,7762,7832,7911,7912,7951,7974,8001,8002,8015,8031,8035,8053,8058,8233,8252,8253,8267,8303,8304,8306,8308,8309,8316,8331,8354,8355,8411,8601,8604,8628,8630,8697,8725,8750,8766,8795,8801,8802,8804,8830,9001,9005,9007,9008,9009,9020,9021,9022,9064,9101,9104,9107,9147,9202,9301,9432,9433,9434,9501,9502,9503,9531,9532,9602,9613,9735,9766,9983,9984]
    let core30 = [3382,4063,4452,4502,4503,4568,6098,6273,6367,6501,6594,6758,6861,6954,6981,7203,7267,7741,7974,8001,8031,8035,8058,8306,8316,8411,8766,9432,9433,9984]
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2{
                    
                }
        })

        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        var ref:DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("SearchIndex").child("main").getData { err, snapshot in
            if err != nil{
                print(err)
                return
            }
            let dict = snapshot.value! as! [String:[String:Any]]
            for key in dict.keys{
                if let company = realm.object(ofType: CompanyRealm.self, forPrimaryKey: key){
                    /*
                    try! realm.write{
                        company.secCode = (dict[key]!["secCode"] as? String)
                        company.simpleCompanyName = (dict[key]!["companyName"] as! String)
                    }
                    */
                }else{
                    let co = CompanyRealm(jcn: key, secCode: dict[key]!["secCode"] as? String, simpleName: dict[key]!["companyName"] as! String)
                    try! realm.write{
                        realm.add(co,update: .modified)
                    }
                }
            }
        }
        
        var N225co:Array<CompanyRealm> = []
        var Core30co:Array<CompanyRealm> = []
        for secCode in n225{
            let company = realm.objects(CompanyRealm.self).filter("secCode == '\(secCode)'")
            if company.count == 0{
                print(secCode)
            }else{
                N225co.append(company[0])
            }
        }
        for secCode in core30{
            let company = realm.objects(CompanyRealm.self).filter("secCode == '\(secCode)'")
            if company.count == 0{
                print(secCode)
            }else{
                Core30co.append(company[0])
            }
        }
        if (realm.object(ofType: CategoryRealm.self, forPrimaryKey: "N225") == nil){
            let category = CategoryRealm(id: "N225", name: "N225", list: N225co)
            try! realm.write{
                realm.add(category,update: .all)
            }
        }
        if (realm.object(ofType: CategoryRealm.self, forPrimaryKey: "Core30") == nil){
            let category = CategoryRealm(id: "Core30", name: "Core30", list: Core30co)
            try! realm.write{
                realm.add(category)
            }
        }
         
        if realm.object(ofType: CategoryRealm.self, forPrimaryKey: "History") == nil{
            let category = CategoryRealm(id: "History", name: "履歴", list: [])
            try! realm.write{ realm.add(category) }
        }
        if realm.object(ofType: CategoryRealm.self, forPrimaryKey: "FAV") == nil{
            let category = CategoryRealm(id: "FAV", name: "お気に入り", list: [])
            try! realm.write{ realm.add(category) }
        }
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

