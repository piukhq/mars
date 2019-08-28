//
//  BrowseBrandsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class BrowseBrandsViewModel {
    private let repository: BrowseBrandsRepository
    private let router: MainScreenRouter
    private var membershipPlans = [MembershipPlanModel]()
    
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
}
