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
    
    func toggleLinkForPaymentCards(membershipCard: CD_MembershipCard, changedLinkCards: [CD_PaymentCard], onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        
        var idsToRemove = [String]()
        var idsToAdd = [String]()
        var fullSuccess = true // assume true
        
        let group = DispatchGroup()
        for paymentCard in changedLinkCards {
            group.enter()
            if membershipCard.linkedPaymentCards.contains(paymentCard) {
                removeLinkToMembershipCard(membershipCard, forPaymentCard: paymentCard) { id in
                    if let id = id {
                        idsToRemove.append(id)
                    } else {
                        fullSuccess = false
                    }
                    group.leave()
                }
            } else {
                linkMembershipCard(withId: membershipCard.id, toPaymentCardWithId: paymentCard.id) { id in
                    if let id = id {
                        idsToAdd.append(id)
                    } else {
                        fullSuccess = false
                    }
                    group.leave()
                }
            }
        }
                
        group.notify(queue: .main) { [weak self] in
            self?.saveChanges(
                toAdd: idsToAdd,
                toRemove: idsToRemove,
                membershipCard: membershipCard) {
                    if fullSuccess {
                        onSuccess()
                    } else {
                        onError()
                    }
            }
        }
    }
}

// MARK: - Private methods

private extension PLLScreenRepository {
    func linkMembershipCard(withId membershipCardId: String, toPaymentCardWithId paymentCardId: String, completion: @escaping (String?) -> Void) {
        let url = RequestURL.linkMembershipCardToPaymentCard(membershipCardId: membershipCardId, paymentCardId: paymentCardId)
        let method: RequestHTTPMethod = .patch
        
        apiManager.doRequest(url: url, httpMethod: method, isUserDriven: false, onSuccess: { (response: PaymentCardModel) in
            completion(response.id)
        }, onError: { error in
            completion(nil)
        })
    }
    
    func removeLinkToMembershipCard(_ membershipCard: CD_MembershipCard, forPaymentCard paymentCard: CD_PaymentCard, completion: @escaping (String?) -> Void) {
        let paymentCardId: String = paymentCard.id
        let membershipCardId: String = membershipCard.id
        let url = RequestURL.linkMembershipCardToPaymentCard(membershipCardId: membershipCardId, paymentCardId: paymentCardId)
        let method: RequestHTTPMethod = .delete
        
        apiManager.doRequest(url: url, httpMethod: method, isUserDriven: false, onSuccess: { (response: PaymentCardModel) in
            completion(paymentCardId)
        }, onError: { error in
            completion(nil)
        })
    }
    
    func saveChanges(toAdd: [String], toRemove: [String], membershipCard: CD_MembershipCard, completion: @escaping () -> Void) {
        Current.database.performBackgroundTask(with: membershipCard) { (context, safeCard) in
            guard let safeCard = safeCard else { return }
            
            if let addResults = context.fetchAllWithApiIDs(CD_PaymentCard.self, ids: toAdd) {
                safeCard.addLinkedPaymentCards(NSSet(array: addResults))
            }
            
            if let removeResults = context.fetchAllWithApiIDs(CD_PaymentCard.self, ids: toRemove) {
                safeCard.removeLinkedPaymentCards(NSSet(array: removeResults))
            }
            
            if context.hasChanges { try? context.save() }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
