//
//  LoyaltyCardFullDetailsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class LoyaltyCardFullDetailsViewModel {
    private let router: MainScreenRouter
    let membershipPlan: MembershipPlanModel
    
    init(membershipPlan: MembershipPlanModel, router: MainScreenRouter) {
        self.router = router
        self.membershipPlan = membershipPlan
    }
    
    func popViewController() {
        router.popViewController()
    }
    
    func displaySimplePopupWithTitle(_ title: String, andMessage message: String) {
        router.displaySimplePopup(title: title, message: message)
    }
}
