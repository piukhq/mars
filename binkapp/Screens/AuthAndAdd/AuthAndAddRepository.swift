//
//  AuthAndAddRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import Alamofire // TODO: We don't want to do this. Find a way to access HTTPMethod without this

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
    
    func addMembershipCard(request: MembershipCardPostModel, formPurpose: FormPurpose, existingMembershipCard: CD_MembershipCard?, onSuccess: @escaping (CD_MembershipCard?) -> (), onError: @escaping (BinkError?) -> ()) {
        let endpoint: APIEndpoint
        let method: HTTPMethod
        
        if let existingCard = existingMembershipCard {
            endpoint = .membershipCard(cardId: existingCard.id)
            method = .put
        } else {
            endpoint = .membershipCards
            method = .post
        }

        let networkRequest = BinkNetworkRequest(endpoint: endpoint, method: method, headers: nil, isUserDriven: true)
        apiClient.performRequestWithParameters(networkRequest, parameters: request, expecting: MembershipCardModel.self) { (result, _) in
            switch result {
            case .success(let response):
                // Map to core data
                Current.database.performBackgroundTask { context in
                    let newObject = response.mapToCoreData(context, .update, overrideID: nil)
                    
                    // The uuid will have already been set in the mapToCoreData call, but thats fine we can set it to the desired value here from the initial post request
                    newObject.uuid = request.uuid

                    try? context.save()

                    DispatchQueue.main.async {
                        Current.database.performTask(with: newObject) { (context, safeObject) in
                            onSuccess(safeObject)
                        }
                    }
                }
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    func postGhostCard(parameters: MembershipCardPostModel, existingMembershipCard: CD_MembershipCard?, onSuccess: @escaping (CD_MembershipCard?) -> Void, onError: @escaping (BinkError?) -> Void) {

        let endpoint: APIEndpoint
        let method: HTTPMethod
        var mutableParams = parameters
        var registrationParams: [PostModel]? = nil

        if let existingCard = existingMembershipCard {
            endpoint = .membershipCard(cardId: existingCard.id)
            method = .patch
            mutableParams.account?.addFields = nil
            mutableParams.account?.authoriseFields = nil
        } else {
            endpoint = .membershipCards
            method = .post
            registrationParams = mutableParams.account?.registrationFields
            mutableParams.account?.registrationFields = nil
        }

        let request = BinkNetworkRequest(endpoint: endpoint, method: method, headers: nil, isUserDriven: true)
        apiClient.performRequestWithParameters(request, parameters: mutableParams, expecting: MembershipCardModel.self) { (result, _) in
            switch result {
            case .success(let response):
                Current.database.performBackgroundTask { context in
                    let newObject = response.mapToCoreData(context, .update, overrideID: nil)

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
            case .failure(let error):
                onError(error)
            }
        }
    }
}
