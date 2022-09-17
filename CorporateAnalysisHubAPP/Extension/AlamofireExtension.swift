//
//  AlamofireExtension.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/09/14.
//
import Alamofire
import Foundation

extension Session{
    open func async_request(url:String,
                       method:HTTPMethod = .get,
                       params:[String:String]? = nil) async throws -> AFDataResponse<Data?> {
        try await withCheckedThrowingContinuation({ continuation in
            self.request(url, method: method, parameters: params).response { res in
                if let err = res.error{
                    continuation.resume(throwing: err)
                }else{
                    continuation.resume(returning: res)
                }
            }
        })
    }
}
