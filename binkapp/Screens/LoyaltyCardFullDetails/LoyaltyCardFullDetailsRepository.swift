//
//  LoyaltyCardFullDetailsRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class LoyaltyCardFullDetailsRepository {
    
    private let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func deleteMembershipCard(id: Int, onSuccess: @escaping (Any) -> Void, onError: @escaping(Error) -> Void) {
        let url = RequestURL.deleteMembershipCard(cardId: id)
        let method = RequestHTTPMethod.delete
        
        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: EmptyResponse) in
            onSuccess(response)
        }, onError: { (error: Error) in
            onError(error)
        })
    }
    
    func getPaymentCards(completion: @escaping ([PaymentCardModel]) -> Void) {
        let url = RequestURL.getPaymentCards
        let httpMethod = RequestHTTPMethod.get
        apiManager.doRequest(url: url, httpMethod: httpMethod, parameters: nil, onSuccess: { (results: [PaymentCardModel]) in
            completion(results)
        }) { (error) in }
    }
}
