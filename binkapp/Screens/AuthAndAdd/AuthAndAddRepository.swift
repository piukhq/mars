//
//  AuthAndAddRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class AuthAndAddRepository: WalletServiceProtocol {
    func addMembershipCard(request: MembershipCardPostModel, formPurpose: FormPurpose, existingMembershipCard: CD_MembershipCard?, onSuccess: @escaping (CD_MembershipCard?) -> (), onError: @escaping (BinkError?) -> ()) {
        addMembershipCard(withRequestModel: request, existingMembershipCard: existingMembershipCard) { (result, rawResponse) in
            switch result {
            case .success(let response):
                // Map to core data
                Current.database.performBackgroundTask { context in
                    let newObject = response.mapToCoreData(context, .update, overrideID: nil)
                    
                    // The uuid will have already been set in the mapToCoreData call, but thats fine we can set it to the desired value here from the initial post request
                    newObject.uuid = request.uuid
                    
                    if let statusCode = rawResponse?.statusCode {
                        BinkAnalytics.track(CardAccountAnalyticsEvent.addLoyaltyCardResponseSuccess(loyaltyCard: newObject, formPurpose: formPurpose, statusCode: statusCode))
                    }
                    
                    try? context.save()
                    
                    DispatchQueue.main.async {
                        Current.database.performTask(with: newObject) { (context, safeObject) in
                            onSuccess(safeObject)
                        }
                    }
                }
            case .failure(let error):
                BinkAnalytics.track(CardAccountAnalyticsEvent.addLoyaltyCardResponseFail(request: request, formPurpose: formPurpose))
                onError(error)
            }
        }
    }
    
    // TODO: I don't like this, can we refactor it?
    func postGhostCard(parameters: MembershipCardPostModel, existingMembershipCard: CD_MembershipCard?, onSuccess: @escaping (CD_MembershipCard?) -> Void, onError: @escaping (BinkError?) -> Void) {
        var mutableModel = parameters
        var registrationModel: [PostModel]? = nil
        if let card = existingMembershipCard {
            mutableModel.account?.addFields = nil
            mutableModel.account?.authoriseFields = nil
            patchGhostCard(withRequestModel: mutableModel, existingMembershipCard: card) { result in
                switch result {
                case .success(let response):
                    Current.database.performBackgroundTask { context in
                        let newObject = response.mapToCoreData(context, .update, overrideID: nil)
                        try? context.save()
                        onSuccess(newObject)
                    }
                case .failure(let error):
                    onError(error)
                }
            }
        } else {
            registrationModel = mutableModel.account?.registrationFields
            mutableModel.account?.registrationFields = nil
            
            addGhostCard(withRequestModel: mutableModel) { result in
                switch result {
                case .success(let response):
                    Current.database.performBackgroundTask { context in
                        let newObject = response.mapToCoreData(context, .update, overrideID: nil)
                        
                        try? context.save()
                        
                        DispatchQueue.main.async {
                            Current.database.performTask(with: newObject) { [weak self] (context, safeObject) in
                                guard let existingCard = safeObject else { return }
                                mutableModel.account?.registrationFields = registrationModel
                                self?.patchGhostCard(withRequestModel: mutableModel, existingMembershipCard: existingCard) { result in
                                    switch result {
                                    case .success(let response):
                                        Current.database.performBackgroundTask { context in
                                            let newObject = response.mapToCoreData(context, .update, overrideID: nil)
                                            try? context.save()
                                            onSuccess(newObject)
                                        }
                                    case .failure(let error):
                                        onError(error)
                                    }
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
}
