//
//  Extension.swift
//  CorporateAnalysisHubAPPTests
//
//  Created by M_Taku on 2022/10/02.
//

@testable import CorporateAnalysisHubAPP


extension MetaData: Equatable {
    public static func == (lhs: MetaData, rhs: MetaData) -> Bool {
        return (lhs.count == rhs.count &&
                lhs.q == rhs.q &&
                lhs.type == rhs.type &&
                lhs.maxResults == rhs.maxResults)
    }
}

extension ApiCompany: Equatable {
    public static func == (lhs: ApiCompany, rhs: ApiCompany) -> Bool {
        return (lhs.jcn == rhs.jcn &&
                lhs.sec_code == rhs.sec_code &&
                lhs.edinet_code == rhs.edinet_code &&
                lhs.name_jp == rhs.name_jp &&
                lhs.name_eng == rhs.name_eng &&
                lhs.num == rhs.num)
    }
}

extension CompanyResponse: Equatable {
    public static func == (lhs: CompanyResponse, rhs: CompanyResponse) -> Bool {
        return (lhs.metadata == rhs.metadata &&
                lhs.results == rhs.results)
    }
}
