//
//  BrowseBrandsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol BrowseBrandsViewModelDelegate: AnyObject {
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
                (firstPlan.account?.companyName?.lowercased() ?? "") < (secondPlan.account?.companyName?.lowercased() ?? "")
            })
            self.selectedFilters = self.mapFilters(fromPlans: self.membershipPlans)
        }
    }
    
    func getMembershipPlan(for indexPath: IndexPath) -> CD_MembershipPlan? {
        switch indexPath.section {
        case 0:
            return getPllMembershipPlans().isEmpty ? (getSeeMembershipPlans().isEmpty ? getStoreMembershipPlans()[safe: indexPath.row]  : getSeeMembershipPlans()[safe: indexPath.row] ) : getPllMembershipPlans()[safe: indexPath.row]
        case 1:
            return getPllMembershipPlans().isEmpty ? getStoreMembershipPlans()[safe: indexPath.row] : (getSeeMembershipPlans().isEmpty ? getStoreMembershipPlans()[safe: indexPath.row] : getSeeMembershipPlans()[safe: indexPath.row])
        case 2:
            return getStoreMembershipPlans()[safe: indexPath.row]
        default:
            break
        }
        return getStoreMembershipPlans()[safe: indexPath.row]
    }
    
    func getSectionTitleText(section: Int) -> String {
        switch section {
        case 0:
            return getPllMembershipPlans().isEmpty ? (getSeeMembershipPlans().isEmpty ? L10n.storeTitle  : L10n.seeTitle) : L10n.pllTitle
        case 1:
            return getPllMembershipPlans().isEmpty ? L10n.storeTitle : (getSeeMembershipPlans().isEmpty ? L10n.storeTitle : L10n.seeTitle)
        case 2:
            return L10n.storeTitle
        default:
            return ""
        }
    }
    
    func getSectionDescriptionText(section: Int) -> NSMutableAttributedString? {
        var descriptionText: String
        switch section {
        case 0:
            descriptionText = getPllMembershipPlans().isEmpty ? (getSeeMembershipPlans().isEmpty ? L10n.storeDescription : L10n.seeDescription) : L10n.pllDescription
        case 1:
            descriptionText = getPllMembershipPlans().isEmpty ? L10n.storeDescription : (getSeeMembershipPlans().isEmpty ? L10n.storeDescription : L10n.seeDescription)
        case 2:
            descriptionText = L10n.storeDescription
        default:
            return nil
        }
        
        let attributedText = NSMutableAttributedString(string: descriptionText, attributes: [.font: UIFont.bodyTextLarge])
        
        if section == 0 && !getPllMembershipPlans().isEmpty {
            let automaticallyRange = NSString(string: attributedText.string).range(of: L10n.pllDescriptionHighlightAutomatically)
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
        return getMembershipPlans().filter { $0.featureSet?.planCardType == .link }
    }
    
    func getSeeMembershipPlans() -> [CD_MembershipPlan] {
        let agentsEnabledForLPS = Current.pointsScrapingManager.agents.filter { Current.pointsScrapingManager.agentEnabled($0) }
        let seePlans = getMembershipPlans().filter { $0.featureSet?.planCardType == .view }

        return seePlans.filter({ plan -> Bool in
            return agentsEnabledForLPS.contains(where: { Int(plan.id) == $0.membershipPlanId })
        })
    }
    
    func getComingSoonBrands() -> [CD_MembershipPlan] {
        return getMembershipPlans().filter { $0.featureSet?.planCardType == .comingSoon }
    }
    
    func getStoreMembershipPlans() -> [CD_MembershipPlan] {
        let pllSeeandComingSoonPlans = getSeeMembershipPlans() + getPllMembershipPlans() + getComingSoonBrands()
        let storePlans = getMembershipPlans().filter { !pllSeeandComingSoonPlans.contains($0) }
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
