//
//  PLLViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PLLScreenViewModel {
    private var membershipCard: CD_MembershipCard
    private let repository: PLLScreenRepository
    private let router: MainScreenRouter
    let isAddJourney: Bool
    var paymentCards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }
    private var changedLinkCards = [CD_PaymentCard]()
    
    var isEmptyPll: Bool {
        if let paymentCards = paymentCards {
            return paymentCards.count == 0
        }
        return true
    }
    
    var linkedPaymentCardIds: [CD_PaymentCard]? {
        let paymentCards = membershipCard.linkedPaymentCards.allObjects as? [CD_PaymentCard]
        return paymentCards
    }
    
    init(membershipCard: CD_MembershipCard, repository: PLLScreenRepository, router: MainScreenRouter, isAddJourney: Bool) {
        self.membershipCard = membershipCard
        self.repository = repository
        self.router = router
        self.isAddJourney = isAddJourney
    }
    
    // MARK:  - Public methods
    
    func popViewController() {
        router.popViewController()
    }
    
    func addCardToChangedCardsArray(card: CD_PaymentCard) {
        if !(changedLinkCards.contains(card)) {
            changedLinkCards.append(card)
        } else {
            if let index = changedLinkCards.firstIndex(of: card) {
                changedLinkCards.remove(at: index)
            }
        }
    }
    
    func reloadPaymentCards(){
        Current.wallet.reload()
    }
    
    func toggleLinkForMembershipCards(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        for paymentCard in changedLinkCards {
            if paymentCardIsLinked(paymentCard) {
                group.enter()
                removeLinkToPaymentCard(paymentCard, completion: {
                    group.leave()
                })
            } else {
                group.enter()
                linkPaymentpCard(withId: paymentCard.id, completion: {
                    group.leave()
                })
            }
        }
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func getMembershipPlan() -> CD_MembershipPlan {
        return membershipCard.membershipPlan ?? CD_MembershipPlan()
    }
    
    func getMembershipCard() -> CD_MembershipCard {
        return membershipCard
    }
    
    func displaySimplePopup(title: String, message: String) {
        router.displaySimplePopup(title: title, message: message)
    }
    
    func toFullDetailsCardScreen() {
        router.toLoyaltyFullDetailsScreen(membershipCard: membershipCard)
    }
    
    func toAddPaymentCardScreen() {
        router.toAddPaymentViewController()
    }
}

// MARK: - Private methods

private extension PLLScreenViewModel {
    func linkPaymentpCard(withId paymentCardId: String, completion: @escaping () -> Void) {
        repository.linkMembershipCard(withId: membershipCard.id, toPaymentCardWithId: paymentCardId, onSuccess: {_ in
            completion()
        }) { (error) in
            self.displaySimplePopup(title: "error_title".localized, message: error.localizedDescription)
        }
    }
    
    func removeLinkToPaymentCard(_ paymentCard: CD_PaymentCard, completion: @escaping () -> Void) {
        repository.removeLinkToMembershipCard(membershipCard, forPaymentCard: paymentCard, onSuccess: {
            completion()
        }) { (error) in
            self.displaySimplePopup(title: "error_title".localized, message: error.localizedDescription)
        }
    }
    
    func paymentCardIsLinked(_ paymentCard: CD_PaymentCard) -> Bool {
        return linkedPaymentCardIds?.contains(paymentCard) ?? false
    }
}
