//
//  FavViewModel.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/09/18.
//


import SwiftUI
import RealmSwift



class FavViewModel{
    @ObservedResults(CategoryRealm.self, filter: NSPredicate(format: "id == 'FAV'")) var fav
}
