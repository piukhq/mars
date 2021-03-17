//
//  BrowseBrandsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

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
            return getPllMembershipPlans().isEmpty ? (getSeeMembershipPlans().isEmpty ? "store_title".localized  : "see_title".localized) : "pll_title".localized
        case 1:
            return getPllMembershipPlans().isEmpty ? "store_title".localized : (getSeeMembershipPlans().isEmpty ? "store_title".localized : "see_title".localized)
        case 2:
            return "store_title".localized
        default:
            return ""
        }
    }
    
    func getSectionDescriptionText(section: Int) -> NSMutableAttributedString? {
        var descriptionText: String
        switch section {
        case 0:
            descriptionText = getPllMembershipPlans().isEmpty ? (getSeeMembershipPlans().isEmpty ? "store_description".localized : "see_description".localized) : "pll_description".localized
        case 1:
            descriptionText = getPllMembershipPlans().isEmpty ? "store_description".localized : (getSeeMembershipPlans().isEmpty ? "store_description".localized : "see_description".localized)
        case 2:
            descriptionText = "store_description".localized
        default:
            return nil
        }
        
        let attributedText = NSMutableAttributedString(string: descriptionText, attributes: [.font: UIFont.bodyTextLarge])
        
        if section == 0 && !getPllMembershipPlans().isEmpty {
            let automaticallyRange = NSString(string: attributedText.string).range(of: "pll_description_highlight_automatically".localized)
            attributedText.addAttributes([.font: UIFont.bodyTextBold], range: automaticallyRange)
        }
        
        return attributedText
    }
    
    func getMembershipPlans() -> [CD_MembershipPlan] {
        if filteredPlans.isEmpty {
            return membershipPlans
        } else {
            return filteredPlans
        }
    }
        
    func getPllMembershipPlans() -> [CD_MembershipPlan] {
        let plans = getMembershipPlans().filter { $0.featureSet?.planCardType == .link }
        return plans.sorted {
            guard let first = $0.account?.companyName?.lowercased() else { return false }
            guard let second = $1.account?.companyName?.lowercased() else { return true }
            
            return first < second
        }
    }
    
    func getSeeMembershipPlans() -> [CD_MembershipPlan] {
        let agentsEnabledForLPS = Current.pointsScrapingManager.agents.filter { Current.pointsScrapingManager.agentEnabled($0) }
        let seePlans = getMembershipPlans().filter { $0.featureSet?.planCardType == .view }

        return seePlans.filter({ plan -> Bool in
            return agentsEnabledForLPS.contains(where: { Int(plan.id) == $0.membershipPlanId })
        })
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
