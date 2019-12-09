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
    
    func brandHeaderWasTapped() {
        let title = membershipCard.membershipPlan?.account?.planName ?? ""
        let description = membershipCard.membershipPlan?.account?.planDescription ?? ""
        
        let attributedString = NSMutableAttributedString()
        let attributedTitle = NSAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : UIFont.headline])
        let attributedBody = NSAttributedString(string: description, attributes: [NSAttributedString.Key.font : UIFont.bodyTextLarge])
        attributedString.append(attributedTitle)
        attributedString.append(attributedBody)
        
        let configuration = ReusableModalConfiguration(title: title, text: attributedString, showCloseButton: true)
        router.toReusableModalTemplateViewController(configurationModel: configuration)
    }
    
    func popViewController() {
        router.popViewController()
    }
}
