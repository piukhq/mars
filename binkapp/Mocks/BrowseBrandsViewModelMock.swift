//
//  BrowseBrandsViewModelMock.swift
//  binkapp
//
//  Created by Paul Tiriteu on 10/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

class BrowseBrandsViewModelMock {
    private let membershipPlans: [MembershipPlanModel]
    
    var shouldShowNoResultsLabel: Bool {
        return filteredPlans.isEmpty
    }
    var searchText = "" {
        didSet {
            filterPlans()
        }
    }
    var filteredPlans = [MembershipPlanModel]()
    
    var filters: [String] {
        return mapFilters(fromPlans: membershipPlans)
    }
    var selectedFilters = [String]() {
        didSet {
            filterPlans()
        }
    }
    
    var existingCardsPlanIDs: [String]? {
        return Current.wallet.membershipCards?.map { ($0.membershipPlan?.id ?? "")}
    }
        
    init(membershipPlans: [MembershipPlanModel]) {
        self.membershipPlans = membershipPlans
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
        if filteredPlans.isEmpty {
            return membershipPlans
        } else {
            return filteredPlans
        }
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
        let plans = getMembershipPlans().filter { $0.featureSet?.cardType == .link }
        return plans.sorted {
            guard let first = $0.account?.companyName?.lowercased() else { return false }
            guard let second = $1.account?.companyName?.lowercased() else { return true }
            
            return first < second
        }
    }
    
    func getNonPllMembershipPlans() -> [MembershipPlanModel] {
        let plans = getMembershipPlans().filter { $0.featureSet?.cardType != .link }
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
    
    private func mapFilters(fromPlans plans: [MembershipPlanModel]) -> [String] {
        let filters = plans.map({ ($0.account?.category ?? "")})
        return filters.uniq(source: filters)
    }
    
    private func filterPlans() {
        filteredPlans = []
        getMembershipPlans().forEach { (plan) in
            guard let companyName = plan.account?.companyName, let category = plan.account?.category else {return}
            if searchText.isEmpty {
                if selectedFilters.contains(category) && !filteredPlans.contains(plan){
                    filteredPlans.append(plan)
                }
            } else {
                if selectedFilters.contains(category) && companyName.localizedCaseInsensitiveContains(searchText) && !filteredPlans.contains(plan){
                    filteredPlans.append(plan)
                }
            }
        }
    }
}

