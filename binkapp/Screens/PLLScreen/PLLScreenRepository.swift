//
//  PLLScreenRepository.swift
//  binkapp
//
//  Created by Pop Dorin on 11/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLLScreenRepository: WalletServiceProtocol {
    func toggleLinkForPaymentCards(membershipCard: CD_MembershipCard, changedLinkCards: [CD_PaymentCard], onSuccess: @escaping () -> Void, onError: @escaping (WalletServiceError?) -> Void) {
        var idsToRemove: [String] = []
        var idsToAdd: [String] = []
        var fullSuccess = true // assume true
        var walletError: WalletServiceError?
        
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
                linkMembershipCard(membershipCard, toPaymentCard: paymentCard) { id, error in
                    if let id = id {
                        idsToAdd.append(id)
                    } else {
                        fullSuccess = false
                        walletError = error
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
                        onError(walletError)
                    }
            }
        }
    }
}

// MARK: - Private methods

private extension PLLScreenRepository {
    // TODO: These two methods could be one
    func linkMembershipCard(_ membershipCard: CD_MembershipCard, toPaymentCard paymentCard: CD_PaymentCard, completion: @escaping (String?, WalletServiceError?) -> Void) {
        toggleMembershipCardPaymentCardLink(membershipCard: membershipCard, paymentCard: paymentCard, shouldLink: true) { result in
            switch result {
            case .success(let response):
                BinkAnalytics.track(PLLAnalyticsEvent.pllPatch(loyaltyCard: membershipCard, paymentCard: paymentCard, response: response))
                completion(response.id, nil)
            case .failure(let walletError):
                BinkAnalytics.track(PLLAnalyticsEvent.pllPatch(loyaltyCard: membershipCard, paymentCard: paymentCard, response: nil))
                completion(nil, walletError)
            }
        }
    }

    func removeLinkToMembershipCard(_ membershipCard: CD_MembershipCard, forPaymentCard paymentCard: CD_PaymentCard, completion: @escaping (String?) -> Void) {
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
                        completion(paymentCard.id)
                    }
                }
            case .failure:
                completion(nil)
            }
        }
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
