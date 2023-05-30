//
//  BrowseBrandsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import SwiftUI

class BrowseBrandsViewModel: ObservableObject {
    private var membershipPlans: [CD_MembershipPlan] = []
    @Published var sections: [[CD_MembershipPlan]] = [[]]
    @Published var scrollToSection: Int = 0
    private var hasNewMerchants = false

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
            .filter { $0.isPlanListable }
            self.selectedFilters = self.mapFilters(fromPlans: self.membershipPlans)
            
            self.configureSections()
        }
    }
    
    func configureSections() {
        let goLiveMerchants = getNewPllMembershipPlans()
        
        if !goLiveMerchants.isEmpty {
            sections = [goLiveMerchants, getPllMembershipPlans(), getSeeMembershipPlans(), getStoreMembershipPlans()]
            hasNewMerchants = true
        } else {
            sections = [getPllMembershipPlans(), getSeeMembershipPlans(), getStoreMembershipPlans()]
        }
    }
    
    func getMembershipPlan(for indexPath: IndexPath) -> CD_MembershipPlan? {
        switch indexPath.section {
        case 0:
            return getPllMembershipPlans().isEmpty ? (getSeeMembershipPlans().isEmpty ? getStoreMembershipPlans()[safe: indexPath.row] : getSeeMembershipPlans()[safe: indexPath.row] ) : getPllMembershipPlans()[safe: indexPath.row]
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
        if !hasNewMerchants {
            switch section {
            case 0:
                return getPllMembershipPlans().isEmpty ? (getSeeMembershipPlans().isEmpty ? L10n.storeTitle : L10n.seeTitle) : L10n.pllTitle
            case 1:
                return getPllMembershipPlans().isEmpty ? L10n.storeTitle : (getSeeMembershipPlans().isEmpty ? L10n.storeTitle : L10n.seeTitle)
            case 2:
                return L10n.storeTitle
            default:
                return ""
            }
        } else {
            switch section {
            case 0:
                return "New for you"
            case 1:
                return getPllMembershipPlans().isEmpty ? (getSeeMembershipPlans().isEmpty ? L10n.storeTitle : L10n.seeTitle) : L10n.pllTitle
            case 2:
                return getPllMembershipPlans().isEmpty ? L10n.storeTitle : (getSeeMembershipPlans().isEmpty ? L10n.storeTitle : L10n.seeTitle)
            case 3:
                return L10n.storeTitle
            default:
                return ""
            }
        }
    }
    
    func getSectionDescriptionText(section: Int) -> AttributedString {
        var descriptionText: String
        
        if !hasNewMerchants {
            switch section {
            case 0:
                descriptionText = getPllMembershipPlans().isEmpty ? (getSeeMembershipPlans().isEmpty ? L10n.storeDescription : L10n.seeDescription) : L10n.pllDescription
            case 1:
                descriptionText = getPllMembershipPlans().isEmpty ? L10n.storeDescription : (getSeeMembershipPlans().isEmpty ? L10n.storeDescription : L10n.seeDescription)
            case 2:
                descriptionText = L10n.storeDescription
            default:
                descriptionText = ""
            }
        } else {
            switch section {
            case 0:
                descriptionText = ""
            case 1:
                descriptionText = getPllMembershipPlans().isEmpty ? (getSeeMembershipPlans().isEmpty ? L10n.storeDescription : L10n.seeDescription) : L10n.pllDescription
            case 2:
                descriptionText = getPllMembershipPlans().isEmpty ? L10n.storeDescription : (getSeeMembershipPlans().isEmpty ? L10n.storeDescription : L10n.seeDescription)
            case 3:
                descriptionText = L10n.storeDescription
            default:
                descriptionText = ""
            }
        }
        
        var attributedText = AttributedString(descriptionText)
        attributedText.font = .bodyTextLarge
        attributedText.foregroundColor = Color(Current.themeManager.color(for: .text))
        
        if !hasNewMerchants && section == 0 && !getPllMembershipPlans().isEmpty {
            if let range = attributedText.range(of: L10n.pllDescriptionHighlightAutomatically) {
                var container = AttributeContainer()
                container.font = .bodyTextBold
                attributedText[range].mergeAttributes(container)
                return attributedText
            }
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
    
    private func isNewMerchant(goLiveDate: String) -> Bool {
        if !goLiveDate.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            guard let liveDate = dateFormatter.date(from: goLiveDate) else { return false }
            
            if liveDate.isBefore(date: Date(), toGranularity: .day) {
                return !Date.hasElapsed(days: 29, since: liveDate)
            }
        }
        
        return false
    }
    
    func getNewPllMembershipPlans() -> [CD_MembershipPlan] {
        return getMembershipPlans().filter { isNewMerchant(goLiveDate: $0.goLive ?? "") }
    }
        
    func getPllMembershipPlans() -> [CD_MembershipPlan] {
        return getMembershipPlans().filter { $0.featureSet?.planCardType == .link }
    }
    
    func getSeeMembershipPlans() -> [CD_MembershipPlan] {
        let agentsEnabledForLPS = Current.pointsScrapingManager.agents.filter { Current.pointsScrapingManager.agentEnabled($0) }

        return getMembershipPlans().filter({ plan -> Bool in
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
        [getNewPllMembershipPlans(), getPllMembershipPlans(), getSeeMembershipPlans(), getStoreMembershipPlans()].forEach {
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
        self.configureSections()
    }
    
    func toAddOrJoinScreen(membershipPlan: CD_MembershipPlan) {
        let viewController = ViewControllerFactory.makeAddOrJoinViewController(membershipPlan: membershipPlan)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
}
