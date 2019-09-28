//
//  AddOrJoinViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class AddOrJoinViewModel {
    private let membershipPlan: CD_MembershipPlan
    private let router: MainScreenRouter
    
    init(membershipPlan: CD_MembershipPlan, router: MainScreenRouter) {
        self.membershipPlan = membershipPlan
        self.router = router
    }
    
    func getMembershipPlan() -> CD_MembershipPlan {
        return membershipPlan
    }
    
    func toAuthAndAddScreen() {
        router.toAuthAndAddViewController(membershipPlan: membershipPlan)
    }
    
    func didSelectAddNewCard() {
        if membershipPlan.featureSet?.planCardType == .link {
            //TODO: go to sign up form
            router.displaySimplePopup(title: "Goes to Sign Up Form", message: "Not implemented yet")
        } else {
            //TODO: native join unavailable
            router.displaySimplePopup(title: "Native Join Unavailable", message: "Not implemented yet")
        }
    }
    
    func displaySimplePopup(title: String?, message: String?) {
        router.displaySimplePopup(title: title, message: message)
    }
    
    func popViewController() {
        router.popViewController()
    }
    
    func popToRootViewController() {
        router.popToRootViewController()
    }
}
