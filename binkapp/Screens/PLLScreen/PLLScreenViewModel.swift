//
//  PLLViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PLLScreenViewModel {
    private let membershipCard: CD_MembershipCard
    private let membershipPlan: CD_MembershipPlan
    private let repository: PLLScreenRepository
    private let router: MainScreenRouter
    var paymentCards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }
    private var paymentCard = CD_PaymentCard()
    
    var isEmptyPll: Bool {
        if let paymentCards = paymentCards {
            return paymentCards.count == 0
        }
        return true
    }
    
    var linkableMembershipCards: [CD_MembershipCard]? {
         return Current.wallet.membershipCards?.filter( { $0.membershipPlan?.featureSet?.planCardType == .link })
     }

     var pllEnabledMembershipCardsCount: Int {
         return linkableMembershipCards?.count ?? 0
     }

     var linkedMembershipCardIds: [String]? {
         let membershipCards = paymentCard.linkedMembershipCards as? Set<CD_MembershipCard>
         return membershipCards?.map { $0.id }
     }

    
    init(membershipCard: CD_MembershipCard, membershipPlan: CD_MembershipPlan, repository: PLLScreenRepository, router: MainScreenRouter) {
        self.membershipCard = membershipCard
        self.membershipPlan = membershipPlan
        self.repository = repository
        self.router = router
    }
    
    // MARK:  - Public methods
    
    func membershipCardIsLinked(_ membershipCard: CD_MembershipCard) -> Bool {
         return linkedMembershipCardIds?.contains(membershipCard.id) ?? false
     }

    func toggleLinkForMembershipCard(_ membershipCard: CD_MembershipCard, completion: @escaping () -> Void) {
         if membershipCardIsLinked(membershipCard) {
             removeLinkToMembershipCard(membershipCard, completion: completion)
         } else {
             linkMembershipCard(withId: membershipCard.id, completion: completion)
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
    func linkMembershipCard(withId membershipCardId: String, completion: @escaping () -> Void) {
        repository.linkMembershipCard(withId: membershipCardId, toPaymentCardWithId: paymentCard.id) { [weak self] paymentCard in
            // If we don't get a payment card back, we'll fail silently by firing the same completion handler anyway.
            // The completion will always be to reload the views, so we will just see the local data.
            if let paymentCard = paymentCard {
                self?.paymentCard = paymentCard
            }

            completion()
        }
    }

    func removeLinkToMembershipCard(_ membershipCard: CD_MembershipCard, completion: @escaping () -> Void) {
        repository.removeLinkToMembershipCard(membershipCard, forPaymentCard: paymentCard, completion: completion)
    }

}
