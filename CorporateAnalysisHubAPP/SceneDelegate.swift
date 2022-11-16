//
//  SceneDelegate.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Takuma on 2021/12/11.
//

// swiftlint:disable force_cast

import UIKit
import AppTrackingTransparency
import AdSupport

@available(iOS 15.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard (scene as? UIWindowScene) != nil else { return }
        let window = UIWindow(windowScene: scene as! UIWindowScene)
        self.window = window
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let HomeVC = storyboard.instantiateViewController(withIdentifier: "TabVC")
        let upDataVC = ConfigAppViewController()
        let vc = (isShouldUpdate() ? upDataVC:HomeVC)
        recommendUpdate()
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

@available(iOS 15.0, *)
extension SceneDelegate {
    
    private func isShouldUpdate() -> Bool {
        let ud = UserDefaults.standard
        let appVersion = AppVersionCheck.appVersion()
        if ud.object(forKey: userState.isFirstBoot.rawValue) == nil {
            return true
        } else if ud.object(forKey: userState.appVersion.rawValue) == nil {
            return true
        } else if !(ud.bool(forKey: userState.isFirstBoot.rawValue)) {
            return true
        } else if ud.string(forKey: userState.appVersion.rawValue) != appVersion {
            return true
        } else {
            return false
        }
    }
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = window else { return }
        window.rootViewController = vc
        
        UIView.transition(with: window, duration: 0.5, options: [.transitionFlipFromRight], animations: nil, completion: nil)

    }
    
    func recommendUpdate() {
        let appVersion = AppVersionCheck.appVersion()
        Task{
            async let recommendVersion = AppVersionCheck.fetchRecommendUpdateVersion()
            async let forceVersion = AppVersionCheck.fetchForceUpdateVersion()
            let recommend = await recommendVersion ?? ""
            let force = await forceVersion ?? ""
            if AppVersionCheck.compareVersion(currentVersion: appVersion, compareVersion: force) {
                let alert = UpdateAlert.force.alertController
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
            } else if AppVersionCheck.compareVersion(currentVersion: appVersion, compareVersion: recommend) {
                let alert = UpdateAlert.recommend.alertController
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
            }
        }
    }
}

enum UpdateAlert {
    case recommend
    case force
    
    var alertController: IRAlertController {
        let alert = IRAlertController(title: "アップデートのお知らせ",
                                      message: "最新版アプリが公開されました。アップデートをお願いします")
        let appstoreAction = IRAlertAction(title: "AppStoreへ", style: .primary) {
            let url = URL(string: "https://apps.apple.com/jp/app/id1616186495")
            UIApplication.shared.open(url!)
        }
        alert.addAction(appstoreAction)

        switch self {
        case .recommend:
            let cancelAction = IRAlertAction(title: "後で", style: .text)
            alert.addAction(cancelAction)
        case .force:
            alert.setAllowAutoDismiss(false)
        }
        return alert
    }
}
