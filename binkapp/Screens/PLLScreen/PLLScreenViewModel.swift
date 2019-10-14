//
//  PLLViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PLLScreenViewModel {
    private var membershipCard: CD_MembershipCard
    private let membershipPlan: CD_MembershipPlan
    private let repository: PLLScreenRepository
    private let router: MainScreenRouter
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
    
    init(membershipCard: CD_MembershipCard, membershipPlan: CD_MembershipPlan, repository: PLLScreenRepository, router: MainScreenRouter) {
        self.membershipCard = membershipCard
        self.membershipPlan = membershipPlan
        self.repository = repository
        self.router = router
    }
    
    // MARK:  - Public methods
    
    func addCardToChangedCardsArray(card: CD_PaymentCard) {
        if !(changedLinkCards.contains(card)) {
            changedLinkCards.append(card)
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
}

private extension PLLScreenViewModel {
    func linkPaymentpCard(withId paymentCardId: String, completion: @escaping () -> Void) {
        repository.linkMembershipCard(withId: membershipCard.id, toPaymentCardWithId: paymentCardId) {_ in
            completion()
        }
    }
    
    func removeLinkToPaymentCard(_ paymentCard: CD_PaymentCard, completion: @escaping () -> Void) {
        repository.removeLinkToMembershipCard(membershipCard, forPaymentCard: paymentCard, completion: completion)
    }
    
    func paymentCardIsLinked(_ paymentCard: CD_PaymentCard) -> Bool {
        return linkedPaymentCardIds?.contains(paymentCard) ?? false
    }
}
