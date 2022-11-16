//
//  AppVersionCheck.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/11/16.
//

import Foundation
import UIKit


struct AppVersionCheck {
    /// iOSのメジャーバージョンを取得する
    /// - Returns: Stringでメジャーバージョンを返す
    static func iosMajorVersion() -> String {
        let systemVersion = UIDevice.current.systemVersion
        let version = systemVersion.components(separatedBy: ".").first
        guard let version = version else { fatalError("iosのメジャーバージョンが取得できませんでした") }
        return version
    }
    
    static func appVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        guard let version = version else { fatalError("appのバージョンが取得できませんでした") }
        return version
    }
    
    static func fetchRecommendUpdateVersion() async -> String? {
        return try? await IR_Alpha.fetchRecommendUpdateVersion()
    }
    
    static func fetchForceUpdateVersion() async -> String? {
        return try? await IR_Alpha.fetchForceUpdateVersion()
    }
    
    
    
    /// バージョンを比較して、Bool値を返す関数
    /// - Parameters:
    ///   - currentVersion l : アプリの現在のバージョン
    ///   - compareVersion r : 比較するバージョン
    /// - Returns: アプリが比較するバージョンより新しい場合False。比較するバージョンより古い場合True。同じバージョンの場合はFalse
    static func compareVersion(currentVersion l: String, compareVersion r: String) -> Bool {
        let lhs = l.components(separatedBy: ".")
        let rhs = r.components(separatedBy: ".")
        for i in 0..<min(lhs.count, rhs.count) {
            if lhs[i] < rhs[i] { return true }
            if lhs[i] > rhs[i] { return false }
        }
        return lhs.count < rhs.count
    }
}
