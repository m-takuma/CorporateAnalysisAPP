//
//  ApiResponseModelTests.swift
//  CorporateAnalysisHubAPPTests
//
//  Created by M_Taku on 2022/10/05.
//

import XCTest
import Network
@testable import CorporateAnalysisHubAPP

class ApiResponseModelTests: XCTestCase {
    let metadata = MetaData(count: 0, q: "", type: "", maxResults: 0)
    let apiCompany = ApiCompany(num: 0, id: 0, jcn: "", edinet_code: "", sec_code: nil, name_jp: "", name_eng: "")
    var companyResponse: CompanyResponse {
        return CompanyResponse(metadata: metadata, results: [apiCompany])
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_MetaData() throws {
        let expect = MetaData(count: 0, q: "", type: "", maxResults: 0)
        XCTAssertEqual(metadata, expect)
    }

    func test_ApiCompany() throws {
        let expect = ApiCompany(num: 0, id: 0, jcn: "", edinet_code: "", sec_code: nil, name_jp: "", name_eng: "")
        XCTAssertEqual(apiCompany, expect)
    }

    func test_CompanyResponse() throws {
        let expect = CompanyResponse(metadata: metadata, results: [apiCompany])
        XCTAssertEqual(companyResponse, expect)
    }
}
