//
//  AuthAndAddRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class AuthAndAddRepository {
    private let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func addMembershipCard(jsonCard: [String: Any], completion: @escaping (MembershipCardModel) -> Void) {
        let url = RequestURL.postMembershipCard
        let method = RequestHTTPMethod.post
        apiManager.doRequest(url: url, httpMethod: method, parameters: jsonCard, onSuccess: { (response: MembershipCardModel) in
            completion(response)
        }, onError: {_ in
            
        })
    }
}
