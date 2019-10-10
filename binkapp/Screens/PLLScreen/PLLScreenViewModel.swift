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
    private let router: MainScreenRouter
    var paymentCards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }
    var isEmptyPll: Bool {
        if let paymentCards = paymentCards {
            return paymentCards.count == 0
        }
        return true
    }
    
    init(membershipCard: CD_MembershipCard, membershipPlan: CD_MembershipPlan, repository: PLLScreenRepository, router: MainScreenRouter) {
        self.membershipCard = membershipCard
        self.membershipPlan = membershipPlan
        self.router = router
    }
    
    // MARK:  - Public methods
    
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
