//
//  AuthAndAddRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct AddMembershipCardRequest {
    let jsonCard: [String: Any]
    let completion: (CD_MembershipCard?) -> Void
    let onError: (Error) -> Void
}

class AuthAndAddRepository {
    private let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func addMembershipCard(request: AddMembershipCardRequest) {
        let url = RequestURL.membershipCards
        let method = RequestHTTPMethod.post
        apiManager.doRequest(url: url, httpMethod: method, parameters: request.jsonCard, onSuccess: { (response: MembershipCardModel) in
            // Map to core data
            Current.database.performBackgroundTask { context in
                let newObject = response.mapToCoreData(context, .none, overrideID: nil)
                
                try? context.save()
                
                DispatchQueue.main.async {
                    Current.database.performTask(with: newObject) { (context, safeObject) in
                        request.completion(safeObject)
                    }
                }
            }
        }, onError: { error in
            print(error)
            request.onError(error)
        })
    }
}
