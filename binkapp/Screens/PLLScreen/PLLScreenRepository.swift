//
//  PLLScreenRepository.swift
//  binkapp
//
//  Created by Pop Dorin on 11/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLLScreenRepository {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func toggleLinkForPaymentCards(membershipCard: CD_MembershipCard, changedLinkCards: [CD_PaymentCard], onSuccess: @escaping () -> Void, onError: @escaping(Error) -> Void) {
        let group = DispatchGroup()
        for paymentCard in changedLinkCards {
            if membershipCard.linkedPaymentCards.contains(paymentCard) {
                group.enter()
                removeLinkToMembershipCard(membershipCard, forPaymentCard: paymentCard, onSuccess: {
                    group.leave()
                }) { (error) in
                    onError(error)
                }
            } else {
                group.enter()
                linkMembershipCard(withId: membershipCard.id, toPaymentCardWithId: paymentCard.id, onSuccess: { (paymentCard) in
                    group.leave()
                }) { (error) in
                    onError(error)
                }
            }
        }
        group.notify(queue: .main) {
            onSuccess()
        }
    }
}

// MARK: - Private methods

private extension PLLScreenRepository {
    func linkMembershipCard(withId membershipCardId: String, toPaymentCardWithId paymentCardId: String, onSuccess: @escaping (CD_PaymentCard?) -> Void, onError: @escaping (Error) -> Void) {
           let url = RequestURL.linkMembershipCardToPaymentCard(membershipCardId: membershipCardId, paymentCardId: paymentCardId)
           let method: RequestHTTPMethod = .patch
           
           apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: PaymentCardModel) in
               Current.database.performBackgroundTask { backgroundContext in
                   // TODO: Should we be using .none here? Only option that works...
                   // It's functional but we're not sure why it doesn't work otherwise and that is concerning.
                   let newObject = response.mapToCoreData(backgroundContext, .none, overrideID: nil)
                   guard let newObjectId = newObject.id else {
                       fatalError("Failed to get the id from the new object.")
                   }
                   
                   try? backgroundContext.save()
                   
                   DispatchQueue.main.async {
                       Current.database.performTask { context in
                           let fetchedObject = context.fetchWithApiID(CD_PaymentCard.self, id: newObjectId)
                           onSuccess(fetchedObject)
                       }
                   }
               }
           }, onError: { error in
               onError(error)
           })
       }
       
       func removeLinkToMembershipCard(_ membershipCard: CD_MembershipCard, forPaymentCard paymentCard: CD_PaymentCard, onSuccess: @escaping () -> Void, onError: @escaping(Error) -> Void) {
           let url = RequestURL.linkMembershipCardToPaymentCard(membershipCardId: membershipCard.id, paymentCardId: paymentCard.id)
           let method: RequestHTTPMethod = .delete
           
           apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: PaymentCardModel) in
               Current.database.performBackgroundTask { context in
                   paymentCard.removeLinkedMembershipCardsObject(membershipCard)
                   
                   try? context.save()
                   
                   DispatchQueue.main.async {
                       onSuccess()
                   }
               }
           }, onError: { error in
               onError(error)
           })
       }
       
}
