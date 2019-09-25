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
    
    init(membershipCard: CD_MembershipCard, router: MainScreenRouter) {
        self.membershipCard = membershipCard
        self.router = router
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
