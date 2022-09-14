//
//  ApiResponseModel.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/09/14.
//

import Foundation
 
public struct MetaData: Codable {
    let count:Int
    let q: String
    let type: String
    let maxResults: Int
}


public struct ApiCompany: Codable {
    let num: Int
    let jcn: String
    let edinet_code: String
    let sec_code: String!
    let name_jp: String
    let name_eng: String
}


public struct CompanyResponse: Codable {
    let metadata: MetaData
    let results: Array<ApiCompany>
}
