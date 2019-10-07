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
    
    func addMembershipCard(jsonCard: [String: Any], completion: @escaping (CD_MembershipCard?) -> Void) throws {
        let url = RequestURL.postMembershipCard
        let method = RequestHTTPMethod.post
        apiManager.doRequest(url: url, httpMethod: method, parameters: jsonCard, onSuccess: { (response: MembershipCardModel) in
            // Map to core data
            Current.database.performBackgroundTask { context in
                let newObject = response.mapToCoreData(context, .none, overrideID: nil)
                
                try? context.save()
                
                DispatchQueue.main.async {
                    Current.database.performTask(with: newObject) { (context, safeObject) in
                        completion(safeObject)
                    }
                }
            }
        }, onError: { error in
            print(error)
            completion(nil)
        })
    }
}
