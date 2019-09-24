//
//  PaymentWalletRepository.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PaymentWalletRepository {
    private let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func getPaymentCards(completion: @escaping ([PaymentCardModel]?) -> Void) {
        let url = RequestURL.getPaymentCards
        let httpMethod = RequestHTTPMethod.get
        apiManager.doRequest(url: url, httpMethod: httpMethod, parameters: nil, onSuccess: { (results: [PaymentCardModel]) in
            completion(results)
        }) { (error) in
            completion(nil)
        }
    }
}
