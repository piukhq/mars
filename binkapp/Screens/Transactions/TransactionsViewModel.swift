//
//  TransactionsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct TransactionsViewModel {
    let membershipCard: MembershipCardModel
    let membershipPlan: MembershipPlanModel
    var transactions: [MembershipTransaction] = []
    private let router: MainScreenRouter
    
    var title: String {
        if transactions.isEmpty {
            return "transaction_history_unavailable_title".localized
        }
        return "points_history_title".localized
    }
    
    var description: String {
        if transactions.isEmpty {
            return "transaction_history_unavailable_description".localized
        }
        return "recent_transaction_history_subtitle".localized
    }
    
    var lastCheckedString: String? {
        let date = Date(timeIntervalSince1970: membershipCard.balances?.first?.updatedAt ?? 0)
        guard let dateString = date.timeAgoString() else { return nil }
        return String(format: "last_checked".localized, dateString)
    }
    
    init(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel, router: MainScreenRouter) {
        self.membershipCard = membershipCard
        self.membershipPlan = membershipPlan
        self.router = router
        
        guard let transactions = membershipCard.membershipTransactions else { return }
        self.transactions = transactions
    }
    
    func displayLoyaltySchemePopup() {
        router.displaySimplePopup(title: membershipPlan.account?.planNameCard, message: membershipPlan.account?.planDescription)
    }
    
    func popViewController() {
        router.popViewController()
    }
}
