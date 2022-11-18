//
//  APITests.swift
//  CorporateAnalysisHubAPPTests
//
//  Created by M_Taku on 2022/10/02.
//

@testable import CorporateAnalysisHubAPP
import XCTest
import gRPC_Core

class APITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_証券コードを指定して一つの結果が得られる() async throws {
        let res = try? await IR_Alpha.companyFind(q: "9983",
                                                type: .sec_code,
                                                maxResults: 100)
        let metaData = MetaData(count: 1, q: "9983", type: IR_Alpha.CompanySearchType.sec_code.rawValue, maxResults: 100)
        let apiCompany = ApiCompany(num: 1, id: 3629, jcn: "9250001000684", edinet_code: "E03217", sec_code: "9983", name_jp: "ファーストリテイリング", name_eng: "FAST RETAILING CO., LTD.")
        let expectValue = CompanyResponse(metadata: metaData, results: [apiCompany])
        XCTAssertEqual(res, expectValue)
    }
}
