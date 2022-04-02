//
//  FireStore.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Takuma on 2022/03/21.
//

import Foundation
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth

class FireStoreFetchDataClass{
    
    private var db:Firestore!
    
    init(){
        db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    func makeCompany_v2(for coreData:CompanyCoreDataClass) async throws -> CompanyDataClass{
        guard coreData.JCN != nil else {
            throw CustomError.NoneJCN
        }
        let collectionRef = db.collection("COMPANY_v2").document(coreData.JCN).collection("FinDoc")
        let company = CompanyDataClass.init(coreData: coreData)
        do{
            let firestore = FireStoreFetchDataClass()
            let snapShot = try await firestore.getDocuments(ref: collectionRef)
            for doc in snapShot.documents{
                let docData = DocData(docID: doc.documentID, companyFinData: doc.data())
                company.finDataDict[doc.documentID] = docData
                async let bsSnapShot = try firestore.getDocument(ref:collectionRef.document(doc.documentID).collection("FinData").document("BS"))
                async let plSnapShot = try firestore.getDocument(ref:collectionRef.document(doc.documentID).collection("FinData").document("PL"))
                async let cfSnapShot = try firestore.getDocument(ref:collectionRef.document(doc.documentID).collection("FinData").document("CF"))
                async let otherSnapShot = try firestore.getDocument(ref:collectionRef.document(doc.documentID).collection("FinData").document("Other"))
                async let finIndexSnapShot = try firestore.getDocument(ref:collectionRef.document(doc.documentID).collection("FinData").document("FinIndexPath"))
                let bs = try await bsSnapShot
                let pl = try await plSnapShot
                let cf = try await cfSnapShot
                let other = try await otherSnapShot
                let fin = try await finIndexSnapShot
                docData.bs = CompanyBSCoreData(bs: bs.data()!)
                docData.pl = CompanyPLCoreData(pl: pl.data()!)
                docData.cf = CompanyCFCoreData(cf: cf.data()!)
                docData.other = CompanyOhterData(other: other.data()!)
                docData.finIndex = CompanyFinIndexData(indexData: fin.data()!)
            }
            return company
        }catch let err{
            throw err as NSError
        }
    }

    func getDocuments(ref:CollectionReference) async throws -> QuerySnapshot{
        try await withCheckedThrowingContinuation({ continuation in
            ref.getDocuments { querySnapshot, err in
                if err != nil || querySnapshot == nil{
                    continuation.resume(throwing: CustomError.NoneSnapShot)
                }else{
                    continuation.resume(returning: querySnapshot!)
                }}})
    }
    func getDocument(ref:DocumentReference) async throws -> DocumentSnapshot{
        try await withCheckedThrowingContinuation({ continuation in
            ref.getDocument { doc, err in
                if err != nil || doc == nil{
                    continuation.resume(throwing: CustomError.NoneSnapShot)
                }else{
                    continuation.resume(returning: doc!)
                }}})
    }
    
    
}

class RealtimeDBFetchClass {
    func getData(ref:DatabaseReference) async throws -> DataSnapshot{
        try await withCheckedThrowingContinuation({ continuation in
            ref.getData { err, data in
                if let err = err{
                    continuation.resume(throwing: err)
                }else{
                    continuation.resume(returning: data)
                }
            }
        })
    }
}


class AuthSignInClass{
    func sigInAnoymously() async throws -> AuthDataResult{
        try await withCheckedThrowingContinuation({ continuation in
            Auth.auth().signInAnonymously { authResults, err in
                if let err = err{
                    continuation.resume(throwing: err as NSError)
                }else{
                    continuation.resume(returning: authResults!)
                }
            }
        })
    }
}
