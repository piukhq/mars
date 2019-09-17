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
    
    init(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel, router: MainScreenRouter) {
        self.membershipCard = membershipCard
        self.membershipPlan = membershipPlan
        self.router = router
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
