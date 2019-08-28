//
//  LoyaltyWalletRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import Alamofire
import Keys

class LoyaltyWalletRepository {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func getMembershipCards(completion: @escaping ([MembershipCardModel]) -> Void) {
        let url = RequestURL.membershipCards
        let method = RequestHTTPMethod.get
        
        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: [MembershipCardModel]) in
            completion(response)
        }, onError: {
            print("error")
        })
    }
    
    func getMembershipPlans(completion: @escaping ([MembershipPlanModel]) -> Void) {
        let url = RequestURL.membershipPlans
        let method = RequestHTTPMethod.get
        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: [MembershipPlanModel]) in
            completion(response)
        }, onError: {
            print("error")
        })
    }
    
    func deleteMembershipCard(id: Int, completion: @escaping (Any) -> Void) {
        let url = RequestURL.deleteMembershipCard(cardId: id)
        let method = RequestHTTPMethod.delete
        
        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: EmptyResponse) in
            completion(response)
        }, onError: {
            print("error")
        })
    }
}
