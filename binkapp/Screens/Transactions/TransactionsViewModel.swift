//
//  TransactionsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

struct TransactionsViewModel {
    let membershipCard: CD_MembershipCard
    var transactions: [CD_MembershipTransaction] = []
    
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
    
    init(membershipCard: CD_MembershipCard) {
        self.membershipCard = membershipCard
        
        guard let transactions = membershipCard.formattedTransactions else { return }
        self.transactions = Array(transactions).sorted(by: {
            if let firstTimestamp = $0.timestamp?.doubleValue, let secondTimestamp = $1.timestamp?.doubleValue {
                return firstTimestamp > secondTimestamp
            } else {
                return $0.id > $1.id
            }
        })
    }
    
    func brandHeaderWasTapped() {
        guard let plan = membershipCard.membershipPlan else { return }
        let viewController = ViewControllerFactory.makeAboutMembershipPlanViewController(membershipPlan: plan)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
}
