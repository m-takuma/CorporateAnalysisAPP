//
//  AppVersionCheckTests.swift
//  CorporateAnalysisHubAPPTests
//
//  Created by M_Taku on 2022/11/16.
//

import XCTest
@testable import CorporateAnalysisHubAPP

class AppVersionCheckTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // compareVersion
    func test_現在のメジャーバージョンが新しい場合() throws {
        let result = AppVersionCheck.compareVersion(currentVersion: "2.1", compareVersion: "1.1")
        XCTAssertFalse(result)
    }
    
    func test_現在のメジャーバージョンが古い場合() throws {
        let result = AppVersionCheck.compareVersion(currentVersion: "1.1", compareVersion: "2.1")
        XCTAssertTrue(result)
    }
    
    func test_現在のマイナーバージョンが新しい場合() throws {
        let result = AppVersionCheck.compareVersion(currentVersion: "1.2", compareVersion: "1.1")
        XCTAssertFalse(result)
    }
    
    func test_現在のマイナーバージョンが古い場合() throws {
        let result = AppVersionCheck.compareVersion(currentVersion: "1.1", compareVersion: "1.2")
        XCTAssertTrue(result)
    }
    
    func test_現在のパッチバージョンが新しい場合() throws {
        let result = AppVersionCheck.compareVersion(currentVersion: "1.1.1", compareVersion: "1.1.0")
        XCTAssertFalse(result)
    }
    
    func test_現在のパッチバージョンが古い場合() throws {
        let result = AppVersionCheck.compareVersion(currentVersion: "1.1.0", compareVersion: "1.1.1")
        XCTAssertTrue(result)
    }
    
    func test_同じバージョンの場合() throws {
        let result = AppVersionCheck.compareVersion(currentVersion: "1.1", compareVersion: "1.1")
        XCTAssertFalse(result)
    }
    
    func test_現在のバージョンにパッチバージョンがない場合() throws {
        let result = AppVersionCheck.compareVersion(currentVersion: "1.1", compareVersion: "1.1.0")
        XCTAssertTrue(result)
    }
    
    func test_比較対象のバージョンにパッチバージョンがない場() throws {
        let result = AppVersionCheck.compareVersion(currentVersion: "1.1.0", compareVersion: "1.1")
        XCTAssertFalse(result)
    }

}
