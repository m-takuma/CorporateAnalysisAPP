//
//  RealmDBModel.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Takuma on 2022/02/27.
//

import Foundation
import RealmSwift

final class CompanyRealm: Object, Identifiable {
    @Persisted(primaryKey: true)var jcn: String!
    @Persisted var secCode: String?
    @Persisted var simpleCompanyName: String?
    convenience init(jcn: String, secCode: String?, simpleName: String) {
        self.init()
        self.jcn = jcn
        self.secCode = secCode
        self.simpleCompanyName = simpleName
    }
}

class CategoryRealm: Object, Identifiable {
    @Persisted(primaryKey: true) dynamic var id: String!
    @Persisted var name: String!
    @Persisted var list = RealmSwift.List<CompanyRealm>()
    convenience init(id: String = UUID().uuidString, name: String, list: [CompanyRealm]) {
        self.init()
        self.id = id
        self.name = name
        self.list.append(objectsIn: list)
    }
}
