//
//  LoyaltyWalletRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import Alamofire
import Keys
import CoreData

class LoyaltyWalletRepository: WalletRepository {
    private let apiManager: ApiManager
    
    required init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }

    func deleteMembershipCard(id: String, completion: @escaping (Any) -> Void) {
        let url = RequestURL.deleteMembershipCard(cardId: id)
        let method = RequestHTTPMethod.delete
        
        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: EmptyResponse) in
            completion(response)
        }, onError: {_ in 
            print("error")
        })
    }
}
