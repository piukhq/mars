//
//  PLLViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PLLScreenViewModel {
    private let membershipPlan: MembershipPlanModel
    private let membershipCard: MembershipCardModel
    private let router: MainScreenRouter
    let paymentCards: [PaymentCardModel]?
    var isEmptyPll: Bool {
        if let paymentCards = paymentCards {
            return paymentCards.count > 0
        }
        return true
    }
    
    init(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel, paymentCards: [PaymentCardModel]? = nil, router: MainScreenRouter) {
        self.membershipCard = membershipCard
        self.membershipPlan = membershipPlan
        self.router = router
        self.paymentCards = paymentCards
    }
    
    // MARK:  - Public methods
    
    func getMembershipPlan() -> MembershipPlanModel {
        return membershipPlan
    }
    
    func displaySimplePopup(title: String, message: String) {
        router.displaySimplePopup(title: title, message: message)
    }
    
    func toFullDetailsCardScreen() {
        router.toLoyaltyFullDetailsScreen(membershipCard: membershipCard, membershipPlan: membershipPlan)
    }
}
