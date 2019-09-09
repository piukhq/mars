//
//  PLLViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PLLViewModel {
    private let membershipPlan: MembershipPlanModel
    private let router: MainScreenRouter
    
    init(membershipPlan: MembershipPlanModel, router: MainScreenRouter) {
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
}
