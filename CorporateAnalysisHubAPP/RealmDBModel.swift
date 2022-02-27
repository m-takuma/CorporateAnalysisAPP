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

