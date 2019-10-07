//
//  PLLViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PLLScreenViewModel {
    private let membershipCard: CD_MembershipCard
    private let router: MainScreenRouter
    let paymentCards: [PaymentCardModel]?
    var isEmptyPll: Bool {
        if let paymentCards = paymentCards {
            return paymentCards.count == 0
        }
        return true
    }
    
    init(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel, paymentCards: [PaymentCardModel]? = nil, router: MainScreenRouter) {
        self.membershipCard = membershipCard
        self.router = router
        self.paymentCards = paymentCards
    }
    
    // MARK:  - Public methods
    
    func getMembershipPlan() -> CD_MembershipPlan {
        return membershipCard.membershipPlan!
    }
    
    func displaySimplePopup(title: String, message: String) {
        router.displaySimplePopup(title: title, message: message)
    }
    
    func toFullDetailsCardScreen() {
        router.toLoyaltyFullDetailsScreen(membershipCard: membershipCard)
    }
}
