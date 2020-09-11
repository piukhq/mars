//
//  AuthAndAddRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class AuthAndAddRepository: WalletServiceProtocol {
    func addMembershipCard(request: MembershipCardPostModel, formPurpose: FormPurpose, existingMembershipCard: CD_MembershipCard?, scrapingCredentials: WebScrapingCredentials? = nil, onSuccess: @escaping (CD_MembershipCard?) -> (), onError: @escaping (BinkError?) -> ()) {
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

                    
                    if Current.pointsScrapingManager.planIdIsWebScrapable(request.membershipPlan) {
                        let pendingStatus = MembershipCardStatusModel(apiId: nil, state: .pending, reasonCodes: [.attemptingToScrapePointsValue])
                        let cdStatus = pendingStatus.mapToCoreData(context, .update, overrideID: MembershipCardStatusModel.overrideId(forParentId: newObject.id))
                        newObject.status = cdStatus
                        cdStatus.card = newObject
                        BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionStatus(membershipCard: newObject))
                    }
                    
                    try? context.save()
                    
                    DispatchQueue.main.async {
                        Current.database.performTask(with: newObject) { (context, safeObject) in
                            if let card = safeObject, let credentials = scrapingCredentials {
                                do {
                                    try Current.pointsScrapingManager.enableLocalPointsScrapingForCardIfPossible(withRequest: request, credentials: credentials, membershipCard: card)
                                } catch {
                                    Current.pointsScrapingManager.transitionToFailed(membershipCard: card)
                                }
                            } else {
                                // TODO: If credentials are nil, force to failed
                            }
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
