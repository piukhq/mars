//
//  PaymentCardDetailRepository.swift
//  binkapp
//
//  Created by Nick Farrant on 08/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PaymentCardDetailRepository: WalletServiceProtocol {
    func getPaymentCard(forId id: String, completion: @escaping (CD_PaymentCard?) -> Void) {
        getPaymentCard(withId: id) { result in
            switch result {
            case .success(let response):
                Current.database.performBackgroundTask { backgroundContext in
                    let newObject = response.mapToCoreData(backgroundContext, .update, overrideID: nil)
                    guard let newObjectId = newObject.id else {
                        fatalError("Failed to get the id from the new object.")
                    }
                    
                    try? backgroundContext.save()
                    
                    DispatchQueue.main.async {
                        Current.database.performTask { context in
                            let fetchedObject = context.fetchWithApiID(CD_PaymentCard.self, id: newObjectId)
                            completion(fetchedObject)
                        }
                    }
                }
            case .failure:
                completion(nil)
            }
        }
    }

    func delete(_ paymentCard: CD_PaymentCard, completion: EmptyCompletionBlock? = nil) {
        let trackableCard = TrackableWalletCard(uuid: paymentCard.uuid, loyaltyPlan: nil, paymentScheme: paymentCard.card?.paymentSchemeIdentifier)
        
        BinkAnalytics.track(CardAccountAnalyticsEvent.deletePaymentCard(card: paymentCard))
        
        deletePaymentCard(paymentCard) { (success, _) in
            guard success else {
                BinkAnalytics.track(CardAccountAnalyticsEvent.deletePaymentCardResponseFail(card: trackableCard))
                return
            }
            BinkAnalytics.track(CardAccountAnalyticsEvent.deletePaymentCardResponseSuccess(card: trackableCard))
        }

        // Process core data deletion
        Current.database.performBackgroundTask(with: paymentCard) { (context, cardToDelete) in
            if let cardToDelete = cardToDelete {
                context.delete(cardToDelete)
            }
            
            try? context.save()
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    func linkMembershipCard(_ membershipCard: CD_MembershipCard, toPaymentCard paymentCard: CD_PaymentCard, completion: @escaping (CD_PaymentCard?) -> Void) {
        toggleMembershipCardPaymentCardLink(membershipCard: membershipCard, paymentCard: paymentCard, shouldLink: true) { result in
            switch result {
            case .success(let response):
                BinkAnalytics.track(PLLAnalyticsEvent.pllPatch(loyaltyCard: membershipCard, paymentCard: paymentCard, response: response))
                
                Current.database.performBackgroundTask { backgroundContext in
                    let newObject = response.mapToCoreData(backgroundContext, .update, overrideID: nil)
                    
                    guard let newObjectId = newObject.id else {
                        fatalError("Failed to get the id from the new object.")
                    }
                    
                    try? backgroundContext.save()
                    
                    DispatchQueue.main.async {
                        
                        Current.database.performTask { context in
                            let fetchedObject = context.fetchWithApiID(CD_PaymentCard.self, id: newObjectId)
                            
                            completion(fetchedObject)
                        }
                    }
                }
            case .failure:
                BinkAnalytics.track(PLLAnalyticsEvent.pllPatch(loyaltyCard: membershipCard, paymentCard: paymentCard, response: nil))
                completion(nil)
                
                
            }
        }
    }

    func removeLinkToMembershipCard(_ membershipCard: CD_MembershipCard, forPaymentCard paymentCard: CD_PaymentCard, completion: @escaping (CD_PaymentCard?) -> Void) {
        toggleMembershipCardPaymentCardLink(membershipCard: membershipCard, paymentCard: paymentCard, shouldLink: false) { result in
            switch result {
            case .success:
                BinkAnalytics.track(PLLAnalyticsEvent.pllDelete(loyaltyCard: membershipCard, paymentCard: paymentCard))
                
                Current.database.performBackgroundTask(with: paymentCard) { (context, safePaymentCard) in
                    
                    if let membershipCardToRemove = context.fetchWithApiID(CD_MembershipCard.self, id: membershipCard.id) {
                        safePaymentCard?.removeLinkedMembershipCardsObject(membershipCardToRemove)
                    }
                    
                    try? context.save()
                    
                    DispatchQueue.main.async {
                        Current.database.performTask { context in
                            let fetchedObject = context.fetchWithApiID(CD_PaymentCard.self, id: paymentCard.id)
                            
                            completion(fetchedObject)
                        }
                    }
                }
            case .failure:
                completion(nil)
            }
        }
    }
}
