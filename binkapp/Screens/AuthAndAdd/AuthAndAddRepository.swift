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
        switch formPurpose {
        case .loginFailed:
            url = .membershipCard(cardId: existingMembershipCard?.id ?? "")
            method = .put
            break
        default:
            url = .membershipCards
            method = .post
            break
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
    
    func postGhostCard(parameters: MembershipCardPostModel, onSuccess: @escaping (CD_MembershipCard?) -> Void, onError: @escaping (Error?) -> Void) {
        apiManager.doRequest(url: .membershipCards, httpMethod: .post, parameters: parameters, onSuccess: { (card: MembershipCardModel) in
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
