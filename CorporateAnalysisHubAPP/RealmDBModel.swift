//
//  RealmDBModel.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2022/02/27.
//

import Foundation
import RealmSwift

class SearchBasicIndex:Object{
    @objc dynamic var jcn:String!
    @objc dynamic var secCode:String? = nil
    @objc dynamic var jpCompanyName:String? = nil
    override class func primaryKey() -> String? {
        return "jcn"
    }
}
class CompanyRealm:Object{
    @objc dynamic var jcn:String!
    @objc dynamic var secCode:String? = nil
    @objc dynamic var simpleCompanyName:String? = nil
    convenience init(jcn:String,secCode:String,simpleName:String) {
        self.init()
        self.jcn = jcn
        self.secCode = secCode
        self.simpleCompanyName = simpleName
    }
    override class func primaryKey() -> String? {
        return "jcn"
    }
}

class CategoryRealm:Object{
    @objc dynamic var id:String!
    @objc dynamic var name:String!
    let list = List<CompanyRealm>()
    convenience init(id:String = UUID().uuidString,name:String,list:[CompanyRealm]) {
        self.init()
        self.id = id
        self.name = name
        self.list.append(objectsIn: list)
    }
}
