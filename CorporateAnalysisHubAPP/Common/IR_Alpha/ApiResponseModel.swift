//
//  ApiResponseModel.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/09/14.
//

import Foundation

// Encode,DecodeできるようにCodable
// 比較できるようにHashable

struct MetaData: Codable, Hashable {
    let count: Int
    let q: String
    let type: String
    let maxResults: Int
}

struct ApiCompany: Codable, Hashable {
    let num: Int
    let jcn: String
    let edinet_code: String
    let sec_code: String!
    let name_jp: String
    let name_eng: String
}

struct CompanyResponse: Codable, Hashable {
    let metadata: MetaData
    let results: [ApiCompany]
}
