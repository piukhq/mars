//
//  PaymentCardDetailRepository.swift
//  binkapp
//
//  Created by Nick Farrant on 08/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PaymentCardDetailRepository: WalletRepository {
    private let apiClient: APIClient

    required init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getPaymentCard(forId id: String, completion: @escaping (CD_PaymentCard?) -> Void) {
        let url = RequestURL.paymentCard(cardId: id)
        let method = RequestHTTPMethod.get

        apiClient.doRequest(url: url, httpMethod: method, isUserDriven: false, onSuccess: { (response: PaymentCardModel) in
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
        }, onError: { _ in
            completion(nil)
        })
    }

    func delete<T: WalletCard>(_ card: T, completion: EmptyCompletionBlock? = nil) {
        // Process the backend delete, but fail silently
        let url = RequestURL.paymentCard(cardId: card.id)
        let method = RequestHTTPMethod.delete
        apiClient.doRequest(url: url, httpMethod: method, isUserDriven: false, onSuccess: { (response: Nothing) in }, onError: { error in })

        // Process core data deletion
        Current.database.performBackgroundTask(with: card) { (context, cardToDelete) in
            if let cardToDelete = cardToDelete {
                context.delete(cardToDelete)
            }

            try? context.save()

            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    func linkMembershipCard(withId membershipCardId: String, toPaymentCardWithId paymentCardId: String, completion: @escaping (CD_PaymentCard?) -> Void) {
        let url = RequestURL.linkMembershipCardToPaymentCard(membershipCardId: membershipCardId, paymentCardId: paymentCardId)
        let method: RequestHTTPMethod = .patch

        apiClient.doRequest(url: url, httpMethod: method, isUserDriven: false, onSuccess: { (response: PaymentCardModel) in
            Current.database.performBackgroundTask { backgroundContext in
                // TODO: Should we be using .none here? Only option that works...
                // It's functional but we're not sure why it doesn't work otherwise and that is concerning.
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
        }, onError: { _ in
            completion(nil)
        })
    }

    func removeLinkToMembershipCard(_ membershipCard: CD_MembershipCard, forPaymentCard paymentCard: CD_PaymentCard, completion: @escaping (CD_PaymentCard?) -> Void) {
        let paymentCardId: String = paymentCard.id
        let membershipCardId: String = membershipCard.id
        let url = RequestURL.linkMembershipCardToPaymentCard(membershipCardId: membershipCardId, paymentCardId: paymentCardId)
        let method: RequestHTTPMethod = .delete
        
        apiClient.doRequest(url: url, httpMethod: method, isUserDriven: false, onSuccess: { (response: PaymentCardModel) in
            Current.database.performBackgroundTask(with: paymentCard) { (context, safePaymentCard) in
                
                if let membershipCardToRemove = context.fetchWithApiID(CD_MembershipCard.self, id: membershipCardId) {
                    safePaymentCard?.removeLinkedMembershipCardsObject(membershipCardToRemove)
                }
                                
                try? context.save()
                
                DispatchQueue.main.async {
                    Current.database.performTask { context in
                        let fetchedObject = context.fetchWithApiID(CD_PaymentCard.self, id: paymentCardId)

                        completion(fetchedObject)
                    }
                }
            }
        }, onError: { _ in
            completion(nil)
        })
    }
}
