//
//  BrowseBrandsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

protocol BrowseBrandsViewModelDelegate: class {
    func browseBrandsViewModel(_ viewModel: BrowseBrandsViewModel, didUpdateFilteredData filteredData: [CD_MembershipPlan])
}

class BrowseBrandsViewModel {
    private var membershipPlans: [CD_MembershipPlan] = []
    
    weak var delegate: BrowseBrandsViewModelDelegate?
    var shouldShowNoResultsLabel: Bool {
        return filteredPlans.isEmpty
    }
    var searchText = "" {
        didSet {
            filterPlans()
        }
    }
    var filteredPlans: [CD_MembershipPlan] = []
    
    var filters: [String] {
        return mapFilters(fromPlans: membershipPlans)
    }
    var selectedFilters: [String] = [] {
        didSet {
            filterPlans()
        }
    }
    
    var existingCardsPlanIDs: [String]? {
        return Current.wallet.membershipCards?.map { ($0.membershipPlan?.id ?? "") }
    }
        
    init() {
        Current.database.performTask { context in
            let plans = context.fetchAll(CD_MembershipPlan.self)
            self.membershipPlans = plans.sorted(by: { (firstPlan, secondPlan) -> Bool in
                (firstPlan.account?.companyName ?? "") < (secondPlan.account?.companyName ?? "")
            })
            self.selectedFilters = self.mapFilters(fromPlans: self.membershipPlans)
        }
    }
    
    func getMembershipPlan(for indexPath: IndexPath) -> CD_MembershipPlan {
        switch indexPath.section {
        case 0:
            return getPllMembershipPlans().isEmpty ? (getSeeMembershipPlans().isEmpty ? getStoreMembershipPlans()[indexPath.row]  : getSeeMembershipPlans()[indexPath.row] ) : getPllMembershipPlans()[indexPath.row]
        case 1:
            return getPllMembershipPlans().isEmpty ? getStoreMembershipPlans()[indexPath.row]  : (getSeeMembershipPlans().isEmpty ? getStoreMembershipPlans()[indexPath.row] : getSeeMembershipPlans()[indexPath.row])
        case 2:
            return getStoreMembershipPlans()[indexPath.row]
        default:
            break
        }
        return getStoreMembershipPlans()[indexPath.row]
    }
    
    func getSectionTitleText(section: Int) -> String {
        switch section {
        case 0:
            return getPllMembershipPlans().isEmpty ? (getSeeMembershipPlans().isEmpty ? "STORE"  : "SEE") : "pll_title".localized
        case 1:
            return getPllMembershipPlans().isEmpty ? "STORE" : (getSeeMembershipPlans().isEmpty ? "STORE" : "SEE")
        case 2:
            return "STORE"
        default:
            return ""
        }
    }
    
    func getMembershipPlans() -> [CD_MembershipPlan] {
        if filteredPlans.isEmpty {
            return membershipPlans
        } else {
            return filteredPlans
        }
    }
    
    // TODO: - Delete

//    func hasMembershipPlans() -> Bool {
//        if !getPllMembershipPlans().isEmpty && !getNonPllMembershipPlans().isEmpty {
//            return true
//        }
//        return false
//    }
//
//    func hasPlansForOneSection() -> Bool {
//        if (getPllMembershipPlans().isEmpty && !getNonPllMembershipPlans().isEmpty) || (!getPllMembershipPlans().isEmpty && getNonPllMembershipPlans().isEmpty) {
//            return true
//        }
//        return false
//    }
        
    func getPllMembershipPlans() -> [CD_MembershipPlan] {
        let plans = getMembershipPlans().filter { $0.featureSet?.planCardType == .link }
        return plans.sorted {
            guard let first = $0.account?.companyName?.lowercased() else { return false }
            guard let second = $1.account?.companyName?.lowercased() else { return true }
            
            return first < second
        }
    }
    
//    func getNonPllMembershipPlans() -> [CD_MembershipPlan] {
//        let plans = getMembershipPlans().filter { $0.featureSet?.planCardType != .link }
//        return plans.sorted {
//            guard let first = $0.account?.companyName?.lowercased() else { return false }
//            guard let second = $1.account?.companyName?.lowercased() else { return true }
//            return first < second
//        }
//    }
    
    func getSeeMembershipPlans() -> [CD_MembershipPlan] {
        let agentsEnabledForLPS = Current.pointsScrapingManager.agents.filter { Current.pointsScrapingManager.agentEnabled($0) }
        let seePlans = getMembershipPlans().filter { $0.featureSet?.planCardType == .view }
        var plansEnabledForScraping: [CD_MembershipPlan] = []

        // TODO: - Refactor
        seePlans.forEach { plan in
            if agentsEnabledForLPS.contains(where: { $0.membershipPlanId == Int(plan.id) }) {
                plansEnabledForScraping.append(plan)
            }
        }
        return plansEnabledForScraping
    }
    
    func getStoreMembershipPlans() -> [CD_MembershipPlan] {
        let pllAndSeePlans = getSeeMembershipPlans() + getPllMembershipPlans()
        let storePlans = getMembershipPlans().filter { !pllAndSeePlans.contains($0) }
        return storePlans
    }
    
    func numberOfSections() -> Int {
        var sections = 0
        [getPllMembershipPlans(), getSeeMembershipPlans(), getStoreMembershipPlans()].forEach {
            if !$0.isEmpty {
                sections += 1
            }
        }
        return sections
    }

    
    func getNumberOfRowsFor(section: Int) -> Int {
        switch section {
        case 0:
            return getPllMembershipPlans().isEmpty ? (getSeeMembershipPlans().isEmpty ? getStoreMembershipPlans().count : getSeeMembershipPlans().count) : getPllMembershipPlans().count
        case 1:
            return getPllMembershipPlans().isEmpty ? getStoreMembershipPlans().count : (getSeeMembershipPlans().isEmpty ? getStoreMembershipPlans().count : getSeeMembershipPlans().count)
        case 2:
            return getStoreMembershipPlans().count
        default:
            return 0
        }
    }
    
    private func mapFilters(fromPlans plans: [CD_MembershipPlan]) -> [String] {
        let filters = plans.map({ ($0.account?.category ?? "") })
        return filters.uniq(source: filters)
    }
    
    private func filterPlans() {
        filteredPlans = []
        getMembershipPlans().forEach { (plan) in
            guard let companyName = plan.account?.companyName, let category = plan.account?.category else { return }
            if searchText.isEmpty {
                if selectedFilters.contains(category) && !filteredPlans.contains(plan) {
                    filteredPlans.append(plan)
                }
            } else {
                if selectedFilters.contains(category) && companyName.localizedCaseInsensitiveContains(searchText) && !filteredPlans.contains(plan) {
                    filteredPlans.append(plan)
                }
            }
        }
        delegate?.browseBrandsViewModel(self, didUpdateFilteredData: filteredPlans)
    }
    
    func toAddOrJoinScreen(membershipPlan: CD_MembershipPlan) {
        let viewController = ViewControllerFactory.makeAddOrJoinViewController(membershipPlan: membershipPlan)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
}
