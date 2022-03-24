//
//  AppDelegate.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2021/12/11.
//

import UIKit
import Firebase
import FirebaseFirestore
import RealmSwift
import GoogleMobileAds
import AdSupport
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var db:Firestore!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        sleep(1)
        
        FirebaseApp.configure()
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        let defaultRealmPath = Realm.Configuration.defaultConfiguration.fileURL!
        let bundleRealmPath = Bundle.main.url(forResource: "init", withExtension: "realm")
        if !FileManager.default.fileExists(atPath: defaultRealmPath.path){
            do{
                try FileManager.default.copyItem(at: bundleRealmPath!, to: defaultRealmPath)
            }catch let err{
                print("error: \(err)")
            }
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
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }


}



