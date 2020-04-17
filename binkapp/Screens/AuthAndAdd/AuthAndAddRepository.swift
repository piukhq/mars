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
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
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
        
        apiClient.doRequest(url: url, httpMethod: method, headers: nil, parameters: request, isUserDriven: true, onSuccess: { (response: MembershipCardModel) in
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
    
    func postGhostCard(parameters: MembershipCardPostModel, existingMembershipCard: CD_MembershipCard?, onSuccess: @escaping (CD_MembershipCard?) -> Void, onError: @escaping (Error?) -> Void) {

        let url: RequestURL
        let method: RequestHTTPMethod
        var mutableParams = parameters
        var registrationParams: [PostModel]? = nil

        if let existingCard = existingMembershipCard {
            url = .membershipCard(cardId: existingCard.id)
            method = .patch
            mutableParams.account?.addFields = nil
            mutableParams.account?.authoriseFields = nil
        } else {
            url = .membershipCards
            method = .post
            registrationParams = mutableParams.account?.registrationFields
            mutableParams.account?.registrationFields = nil
        }

        apiClient.doRequest(url: url, httpMethod: method, parameters: mutableParams, isUserDriven: true, onSuccess: { (card: MembershipCardModel) in
            Current.database.performBackgroundTask { context in
                let newObject = card.mapToCoreData(context, .update, overrideID: nil)

                try? context.save()

                DispatchQueue.main.async {
                    Current.database.performTask(with: newObject) { [weak self] (context, safeObject) in
                        
                        if method == .post {
                            
                            mutableParams.account?.registrationFields = registrationParams
                            
                            self?.postGhostCard(
                                parameters: mutableParams,
                                existingMembershipCard: safeObject,
                                onSuccess: onSuccess,
                                onError: onError
                            )
                        } else {
                            onSuccess(safeObject)
                        }
                    }
                }
            }
        }) { error in
            onError(error)
        }
    }
}
