//
//  PLLScreenRepository.swift
//  binkapp
//
//  Created by Pop Dorin on 11/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLLScreenRepository {
    let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
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
        // TODO: Request should become a static let in a service in future ticket
        let request = BinkNetworkRequest(endpoint: .linkMembershipCardToPaymentCard(membershipCardId: membershipCardId, paymentCardId: paymentCardId), method: .patch, headers: nil, isUserDriven: false)
        apiClient.performRequest(request, expecting: PaymentCardModel.self) { result in
            switch result {
            case .success(let response):
                completion(response.id)
            case .failure:
                completion(nil)
            }
        }
    }

    func removeLinkToMembershipCard(_ membershipCard: CD_MembershipCard, forPaymentCard paymentCard: CD_PaymentCard, completion: @escaping (String?) -> Void) {
        // TODO: Request should become a static let in a service in future ticket
        let request = BinkNetworkRequest(endpoint: .linkMembershipCardToPaymentCard(membershipCardId: membershipCard.id, paymentCardId: paymentCard.id), method: .delete, headers: nil, isUserDriven: false)
        apiClient.performRequest(request, expecting: PaymentCardModel.self) { result in
            switch result {
            case .success:
                completion(paymentCard.id)
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
