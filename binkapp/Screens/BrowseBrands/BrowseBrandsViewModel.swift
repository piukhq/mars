//
//  BrowseBrandsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

enum PlanCardType: Int {
    case pll = 2
    case nonPll
}

class BrowseBrandsViewModel {
    private let repository: BrowseBrandsRepository
    private let router: MainScreenRouter
    private var membershipPlans = [MembershipPlanModel]()
    
    var pllMembershipPlans: [MembershipPlanModel] {
        var plansArray: [MembershipPlanModel] = []
        for plan in membershipPlans {
            if plan.featureSet?.cardType == PlanCardType.pll.rawValue {
                plansArray.append(plan)
            }
        }
        return plansArray
    }
    
    var nonPllMembershipPlans: [MembershipPlanModel] {
        var plansArray: [MembershipPlanModel] = []
        for plan in membershipPlans {
            if plan.featureSet?.cardType != PlanCardType.pll.rawValue {
                plansArray.append(plan)
            }
        }
        return plansArray
    }
    
    init(repository: BrowseBrandsRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
        
        let defaults = UserDefaults.standard
        if let encodedMembershipPlans = defaults.object(forKey: "MembershipPlans") as? Data {
            let decoder = JSONDecoder()
            if let plans = try? decoder.decode([MembershipPlanModel].self, from: encodedMembershipPlans) {
                self.membershipPlans = plans.sorted(by: { (firstPlan, secondPlan) -> Bool in
                    (firstPlan.account?.companyName)! < (secondPlan.account?.companyName)!
                })
            }
        }
    }
    
    func getMembershipPlans() -> [MembershipPlanModel] {
        return membershipPlans
    }
    
    func toAddOrJoinScreen(membershipPlan: MembershipPlanModel) {
        router.toAddOrJoinViewController(membershipPlan: membershipPlan)
    }
    
    func popViewController() {
        router.popViewController()
    }
}
