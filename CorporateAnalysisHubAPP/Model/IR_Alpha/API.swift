//
//  API.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/09/14.
//
import Alamofire
import Foundation

extension IR_Alpha {
    enum CompanySearchType: String{
        case jcn, edinet_code, sec_code, name_jp, name_eng
    }
}

class IR_Alpha {
    private let endPoint = "http://ir-alpha.com"
    private let company = "company"
    func companyFind(q:String,
                     type:IR_Alpha.CompanySearchType,
                     maxResults: UInt = 100) async throws -> CompanyResponse {
        let url = endPoint + "/" + company
        let params = [
            "q": q,
            "type": type.rawValue,
            "maxResults": String(maxResults)
        ]
        do{
            let res = try await AF.async_request(url: url, params: params)
            let value = try JSONDecoder().decode(CompanyResponse.self, from: res.value!!)
            return value
        }catch let err{
            throw err
        }
    }
}