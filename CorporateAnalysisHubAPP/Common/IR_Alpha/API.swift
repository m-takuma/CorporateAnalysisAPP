//
//  API.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/09/14.
//
import Alamofire
import SwiftyJSON
import Foundation

extension IR_Alpha {
    enum CompanySearchType: String {
        case jcn, edinet_code, sec_code, name_jp, name_eng
    }
}

private let endPoint = "http://ir-alpha.com"
private let company = "company"
private let appVersions = "app_versions"

struct IR_Alpha {
    
    static func companyFind(q: String,
                            type: IR_Alpha.CompanySearchType,
                            maxResults: UInt = 100) async throws -> CompanyResponse {
        let url = endPoint + "/api/v0/" + company
        let params = [
            "q": q,
            "type": type.rawValue,
            "maxResults": String(maxResults)
        ]
        do {
            let res = try await AF.async_request(url: url, params: params)
            guard let data = res.data else { throw res.error ?? fatalError() }
            let value = try JSONDecoder().decode(CompanyResponse.self, from: data)
            return value
        } catch let err {
            throw err
        }
    }
    
    static func findFinDocument(company_id: Int, quarter: Bool = false) async -> [FinDocument] {
        let url = endPoint + "/api/v0/" + "document"
        let params = ["company_id": String(company_id), "quarter": String(quarter)]
        do {
            let res = try await AF.async_request(url: url, method: .get, params: params)
            guard let data = res.data else { throw res.error ?? fatalError() }
            let jsonData = try JSON(data: data)["results"].array
            guard let jsonData = jsonData else { return [] }
            var results = jsonData.map { try? JSONDecoder().decode(FinDocument.self, from: $0.rawData()) }
            results.removeAll { $0 == nil }
            return results as? [FinDocument] ?? []
        } catch _ {
            return []
        }
    }
    
    static func fetchRecommendUpdateVersion() async -> String? {
        let url = endPoint + "/api/v0/" + "app_versions"
        let res = try? await AF.async_request(url: url)
        guard let data = res?.data else { return nil }
        let jsonData = try? JSON(data: data)
        let iosVersion = AppVersionCheck.iosMajorVersion()
        let recommendVersion = jsonData?["ios"][iosVersion]["recommend"]
        return recommendVersion?.string
    }
    
    static func fetchForceUpdateVersion() async -> String? {
        let url = endPoint + "/api/v0/" + "app_versions"
        let res = try? await AF.async_request(url: url)
        guard let data = res?.data else { return nil }
        let jsonData = try? JSON(data: data)
        let iosVersion = AppVersionCheck.iosMajorVersion()
        let recommendVersion = jsonData?["ios"][iosVersion]["force"]
        return recommendVersion?.string
    }
}
