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
    
    func getMembershipPlan(for indexPath: IndexPath) -> MembershipPlanModel {
        if indexPath.section == 0 {
            return getPllMembershipPlans().isEmpty ? getNonPllMembershipPlans()[indexPath.row] : getPllMembershipPlans()[indexPath.row]
        }
        return getNonPllMembershipPlans()[indexPath.row]
    }
    
    func getSectionTitleText(section: Int) -> String {
        if section == 0 {
            if !getPllMembershipPlans().isEmpty {
                return "pll_title".localized
            }
        }
        return "all_title".localized
    }
    
    func getMembershipPlans() -> [MembershipPlanModel] {
        return membershipPlans
    }
    
    func hasMembershipPlans() -> Bool {
        if !getPllMembershipPlans().isEmpty && !getNonPllMembershipPlans().isEmpty {
            return true
        }
        return false
    }
    
    func hasPlansForOneSection() -> Bool {
        if (getPllMembershipPlans().isEmpty && !getNonPllMembershipPlans().isEmpty) || (!getPllMembershipPlans().isEmpty && getNonPllMembershipPlans().isEmpty) {
            return true
        }
        return false
    }
    
    func getPllMembershipPlans() -> [MembershipPlanModel] {
        var plansArray: [MembershipPlanModel] = []
        for plan in membershipPlans {
            if plan.featureSet?.cardType == PlanCardType.pll.rawValue {
                plansArray.append(plan)
            }
        }
        return plansArray
    }
    
    func getNonPllMembershipPlans() -> [MembershipPlanModel] {
        var plansArray: [MembershipPlanModel] = []
        for plan in membershipPlans {
            if plan.featureSet?.cardType != PlanCardType.pll.rawValue {
                plansArray.append(plan)
            }
        }
        return plansArray
    }
    
    func numberOfSections() -> Int {
        var sections = 0
        [getPllMembershipPlans(), getNonPllMembershipPlans()].forEach {
            if !$0.isEmpty {
                sections += 1
            }
        }
        return sections
    }

    
    func getNumberOfRowsFor(section: Int) -> Int {
        switch section {
        case 0:
            return getPllMembershipPlans().isEmpty ? getNonPllMembershipPlans().count : getPllMembershipPlans().count
        case 1:
            return getNonPllMembershipPlans().count
        default:
            return 0
        }
    }
    
    func toAddOrJoinScreen(membershipPlan: MembershipPlanModel) {
        router.toAddOrJoinViewController(membershipPlan: membershipPlan)
    }
    
    func popViewController() {
        router.popViewController()
    }
}
