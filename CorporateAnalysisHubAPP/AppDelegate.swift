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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        /*
        db = Firestore.firestore()
        let realm = try! Realm()
        let jpNameIndexRef = db.collection("Search").document("JPName")
        jpNameIndexRef.getDocument { document, error in
            let data = document!.data()!
            for jcn in data.keys{
                if let basicIndex = realm.object(ofType: SearchBasicIndex.self, forPrimaryKey: jcn){
                    try! realm.write{
                        basicIndex.jpCompanyName = (data[jcn] as! String)
                    }
                }else{
                    let basicIndex = SearchBasicIndex()
                    basicIndex.jcn = jcn
                    basicIndex.jpCompanyName = (data[jcn] as! String)
                    try! realm.write{
                        realm.add(basicIndex,update: .modified)
                    }
                }
                
            }
        }
        let secCodeIndexRef = db.collection("Search").document("SecCode")
        secCodeIndexRef.getDocument { document, error in
            let data = document!.data()!
            for jcn in data.keys{
                if let basicIndex = realm.object(ofType: SearchBasicIndex.self, forPrimaryKey: jcn){
                    try! realm.write{
                        basicIndex.secCode = (data[jcn] as! String)
                    }
                }else{
                    let basicIndex = SearchBasicIndex()
                    basicIndex.jcn = jcn
                    basicIndex.secCode = (data[jcn] as! String)
                    try! realm.write{
                        realm.add(basicIndex,update: .modified)
                    }
                }
            }
        }
         */
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

