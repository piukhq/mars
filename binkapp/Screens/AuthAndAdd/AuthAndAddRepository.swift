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
    
    func addMembershipCard(request: AddMembershipCardRequest, formPurpose: FormPurpose, existingMembershipCard: CD_MembershipCard?) {
        var url: RequestURL?
        var method: RequestHTTPMethod?
        switch formPurpose {
        case .login:
            url = .membershipCards
            method = .post
            break
        case .loginFailed:
            url = .membershipCard(cardId: existingMembershipCard?.id ?? "")
            method = .put
            break
        default:
            break
        }
        
        apiManager.doRequest(url: url ?? .membershipCards, httpMethod: method ?? .post, parameters: request.jsonCard, onSuccess: { (response: MembershipCardModel) in
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
    
    func postGhostCard(parameters: [String: Any], onSuccess: @escaping (CD_MembershipCard?) -> Void, onError: @escaping (Error) -> Void) {
        apiManager.doRequest(url: .membershipCards, httpMethod: .post, parameters: parameters, onSuccess: { (card: MembershipCardModel) in
            Current.database.performBackgroundTask { context in
                let newObject = card.mapToCoreData(context, .none, overrideID: nil)
                
                try? context.save()
                
                DispatchQueue.main.async {
                    Current.database.performTask(with: newObject) { (context, safeObject) in
                        onSuccess(safeObject)
                    }
                }
            }
        }) { (error) in
            onError(error)
        }
    }
    
    func patchGhostCard(cardId: String, parameters: [String: Any]) {
        apiManager.doRequest(url: .membershipCard(cardId: cardId), httpMethod: .patch, parameters: parameters, onSuccess: { (response: MembershipCardModel) in
            
        }) { (error) in
            
        }
    }
}
