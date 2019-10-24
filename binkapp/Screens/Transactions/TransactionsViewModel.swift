//
//  TransactionsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct TransactionsViewModel {
    let membershipCard: CD_MembershipCard
    var transactions: [CD_MembershipTransaction] = []
    private let router: MainScreenRouter
    
    var title: String {
//        if transactions.isEmpty {
//            return "transaction_history_unavailable_title".localized
//        }
        return "points_history_title".localized
    }
    
    var description: String {
//        if transactions.isEmpty {
//            return String(format: "transaction_history_unavailable_description".localized, membershipCard.membershipPlan?.account?.planName ?? "")
//        }
        return "recent_transaction_history_subtitle".localized
    }
    
    var lastCheckedString: String? {
        let date = Date(timeIntervalSince1970: membershipCard.formattedBalances?.first?.updatedAt?.doubleValue ?? 0)
        guard let dateString = date.timeAgoString() else { return nil }
        return String(format: "last_checked".localized, dateString)
    }
    
    init(membershipCard: CD_MembershipCard, router: MainScreenRouter) {
        self.membershipCard = membershipCard
        self.router = router
        
        guard let transactions = membershipCard.formattedTransactions else { return }
        self.transactions = Array(transactions).sorted(by: {
            if let firstTimestamp = $0.timestamp?.doubleValue, let secondTimestamp = $1.timestamp?.doubleValue {
                return firstTimestamp > secondTimestamp
            } else {
                return $0.id > $1.id
            }
        })
    }
    
    func displayLoyaltySchemePopup() {
        router.displaySimplePopup(title: membershipCard.membershipPlan?.account?.planNameCard, message: membershipCard.membershipPlan?.account?.planDescription)
    }
    
    func popViewController() {
        router.popViewController()
    }
}
