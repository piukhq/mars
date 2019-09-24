//
//  AddOrJoinViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class AddOrJoinViewModel {
    private let membershipPlan: MembershipPlanModel
    private let router: MainScreenRouter
    
    init(membershipPlan: MembershipPlanModel, router: MainScreenRouter) {
        self.membershipPlan = membershipPlan
        self.router = router
    }
    
    func getMembershipPlan() -> MembershipPlanModel {
        return membershipPlan
    }
    
    func toAuthAndAddScreen() {
        router.toAuthAndAddViewController(membershipPlan: membershipPlan)
    }
    
    func newCardWasPresed() {
        if membershipPlan.featureSet?.cardType == FeatureSetModel.PlanCardType.link {
            //TODO: go to sign up form
            print("goes to sign up")
        } else {
            //TODO: native join unavailable
            print("native join unavailable")
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
