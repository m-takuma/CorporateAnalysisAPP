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
    let id: Int
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

struct FinDocument: Codable, Hashable, IrAlphaFormatter {
    let id: Int
    let document_uid: String
    let current_fiscalyear_startdate: String
    let current_fiscalyear_enddate: String
    let current_period_enddate: String
    let is_consolidated: Bool
    let document_type: String
    let company_id: Int
    let accounting_standard_id: Int
    let dei_industry_code_id: Int
    let period_type_id: Int
}

protocol IrAlphaFormatter {
    func formatter(date: String) -> Date?
}

extension IrAlphaFormatter {
    func formatter(date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd"
        return formatter.date(from: date)
    }
}
