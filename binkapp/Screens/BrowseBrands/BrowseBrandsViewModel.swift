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
    private var membershipPlans = [CD_MembershipPlan]()
    
    init(repository: BrowseBrandsRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router

        Current.database.performTask { context in
            let plans = context.fetchAll(CD_MembershipPlan.self)
            self.membershipPlans = plans.sorted(by: { (firstPlan, secondPlan) -> Bool in
                (firstPlan.account?.companyName)! < (secondPlan.account?.companyName)!
            })
        }
    }
    
    func getMembershipPlan(for indexPath: IndexPath) -> CD_MembershipPlan {
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
    
    func getMembershipPlans() -> [CD_MembershipPlan] {
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
    
    func getPllMembershipPlans() -> [CD_MembershipPlan] {
        let plans = membershipPlans.filter { $0.featureSet?.planCardType == .link }
        return plans.sorted {
            guard let first = $0.account?.companyName?.lowercased() else { return false }
            guard let second = $1.account?.companyName?.lowercased() else { return true }
            
            return first < second
        }
    }
    
    func getNonPllMembershipPlans() -> [CD_MembershipPlan] {
        let plans = membershipPlans.filter { $0.featureSet?.planCardType != .link }
        return plans.sorted {
            guard let first = $0.account?.companyName?.lowercased() else { return false }
            guard let second = $1.account?.companyName?.lowercased() else { return true }
            
            return first < second
        }
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
    
    func toAddOrJoinScreen(membershipPlan: CD_MembershipPlan) {
        router.toAddOrJoinViewController(membershipPlan: membershipPlan)
    }
    
    func popViewController() {
        router.popViewController()
    }
}
