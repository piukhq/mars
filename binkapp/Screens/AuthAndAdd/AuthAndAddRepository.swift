//
//  AuthAndAddRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

//struct AddMembershipCardRequest {
//    let jsonCard: [String: Any]
//    let completion: (CD_MembershipCard?) -> Void
//    let onError: (Error) -> Void
//}

class AuthAndAddRepository {
    private let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func addMembershipCard(request: MembershipCardPostModel, formPurpose: FormPurpose, existingMembershipCard: CD_MembershipCard?, onSuccess: @escaping (CD_MembershipCard?) -> (), onError: @escaping (Error?) -> ()) {
        let url: RequestURL
        let method: RequestHTTPMethod
        
        if let existingCard = existingMembershipCard {
            url = .membershipCard(cardId: existingCard.id)
            method = .put
        } else {
            url = .membershipCards
            method = .post
        }
        
        apiManager.doRequest(url: url, httpMethod: method, headers: nil, parameters: request, onSuccess: { (response: MembershipCardModel) in
            // Map to core data
            Current.database.performBackgroundTask { context in
                let newObject = response.mapToCoreData(context, .update, overrideID: nil)

                try? context.save()

                DispatchQueue.main.async {
                    Current.database.performTask(with: newObject) { (context, safeObject) in
                        onSuccess(safeObject)
                    }
                }
            }
        }, onError: onError)
    }
    
    func postGhostCard(parameters: MembershipCardPostModel, existingMembershipCard: CD_MembershipCard? = nil, onSuccess: @escaping (CD_MembershipCard?) -> Void, onError: @escaping (Error?) -> Void) {
        var method = RequestHTTPMethod.post
        var url = RequestURL.membershipCards
        
        if let existingCard = existingMembershipCard {
            method = .put
            url = .membershipCard(cardId: existingCard.id)
        }
        
        apiManager.doRequest(url: url, httpMethod: method, parameters: parameters, onSuccess: { (card: MembershipCardModel) in
            Current.database.performBackgroundTask { context in
                let newObject = card.mapToCoreData(context, .update, overrideID: nil)

                try? context.save()

                DispatchQueue.main.async {
                    Current.database.performTask(with: newObject) { (context, safeObject) in
                        onSuccess(safeObject)
                    }
                }
            }
        }) { error in
            onError(error)
        }
    }
    
    func patchGhostCard(cardId: String, parameters: MembershipCardPostModel) {
        apiManager.doRequest(url: .membershipCard(cardId: cardId), httpMethod: .patch, parameters: parameters, onSuccess:
            { (response: MembershipCardModel) in }
        )
    }
}
