//
//  AuthAndAddRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class AuthAndAddRepository: WalletServiceProtocol {
    func addMembershipCard(request: MembershipCardPostModel, formPurpose: FormPurpose, existingMembershipCard: CD_MembershipCard?, scrapingCredentials: WebScrapingCredentials? = nil, onSuccess: @escaping (CD_MembershipCard?) -> Void, onError: @escaping (BinkError?) -> Void) {
        guard !request.isCustomCard else {
            mapCustomCardToCoreData(membershipCard: request, completion: { membershipCard in
                onSuccess(membershipCard)
            })
            return
        }
        
        addMembershipCard(withRequestModel: request, existingMembershipCard: existingMembershipCard) { (result, responseData) in
            switch result {
            case .success(let response):
                // Map to core data
                Current.database.performBackgroundTask { context in
                    let newObject = response.mapToCoreData(context, .update, overrideID: nil)
                    
                    // The uuid will have already been set in the mapToCoreData call, but thats fine we can set it to the desired value here from the initial post request
                    newObject.uuid = request.uuid

                    if let statusCode = responseData?.urlResponse?.statusCode {
                        BinkAnalytics.track(CardAccountAnalyticsEvent.addLoyaltyCardResponseSuccess(loyaltyCard: newObject, formPurpose: formPurpose, statusCode: statusCode))
                    }
                    
                    let logData = formPurpose.planDocumentDisplayMatching.rawValue + " - " + newObject.id
                    BinkLogger.infoPrivateHash(event: LoyaltyCardLoggerEvent.loyaltyCardAdded, value: logData)
                    
                    if Current.pointsScrapingManager.planIdIsWebScrapable(request.membershipPlan) {
                        let pendingStatus = MembershipCardStatusModel(apiId: nil, state: .pending, reasonCodes: [.attemptingToScrapePointsValue])
                        let cdStatus = pendingStatus.mapToCoreData(context, .update, overrideID: MembershipCardStatusModel.overrideId(forParentId: newObject.id))
                        newObject.status = cdStatus
                        cdStatus.card = newObject
                        BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionStatus(membershipCard: newObject))
                    }
                    
                    try? context.save()
                    
                    DispatchQueue.main.async {
                        Current.database.performTask(with: newObject) { (_, safeObject) in
                            if let card = safeObject, let credentials = scrapingCredentials {
                                try? Current.pointsScrapingManager.enableLocalPointsScrapingForCardIfPossible(withRequest: request, credentials: credentials, membershipCard: card)
                            }
                            onSuccess(safeObject)
                        }
                    }
                }
                
            case .failure(let error):
                BinkAnalytics.track(CardAccountAnalyticsEvent.addLoyaltyCardResponseFail(request: request, formPurpose: formPurpose, responseData: responseData))
                BinkLogger.error(LoyaltyCardLoggerError.addLoyaltyCardFailure, value: responseData?.urlResponse?.statusCode.description)
                onError(error)
            }
        }
    }
    
    func mapCustomCardToCoreData(membershipCard: MembershipCardPostModel, completion: @escaping (CD_MembershipCard?) -> Void) {
        Current.database.performBackgroundTask { context in
            let barcode = membershipCard.account?.addFields?.first(where: { $0.column == "Card number" })?.value
            let cardModel = CardModel(apiId: nil, barcode: barcode, colour: nil, secondaryColour: nil)
            
            let membershipCardModel = MembershipCardModel(apiId: Int(membershipCard.uuid),
                                                          membershipPlan: membershipCard.membershipPlan,
                                                          card: cardModel,
                                                          images: nil,
                                                          openedTime: nil)
            
            let newObject = membershipCardModel.mapToCoreData(context, .update, overrideID: nil)
            try? context.save()
            
            DispatchQueue.main.async {
                Current.database.performTask(with: newObject) { (_, safeObject) in
                    completion(safeObject)
                }
            }
        }
    }
    
    // TODO: I don't like this, can we refactor it?
    func postGhostCard(parameters: MembershipCardPostModel, existingMembershipCard: CD_MembershipCard?, onSuccess: @escaping (CD_MembershipCard?) -> Void, onError: @escaping (BinkError?) -> Void) {
        var mutableModel = parameters
        var registrationModel: [PostModel]?
        if let card = existingMembershipCard {
            mutableModel.account?.addFields = nil
            mutableModel.account?.authoriseFields = nil
            patchGhostCard(withRequestModel: mutableModel, existingMembershipCard: card) { result in
                switch result {
                case .success(let response):
                    Current.database.performBackgroundTask { context in
                        let newObject = response.mapToCoreData(context, .update, overrideID: nil)
                        try? context.save()
                        
                        DispatchQueue.main.async {
                            Current.database.performTask(with: newObject) { (_, safeObject) in
                                guard let existingCard = safeObject else { return }
                                onSuccess(existingCard)
                            }
                        }
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
