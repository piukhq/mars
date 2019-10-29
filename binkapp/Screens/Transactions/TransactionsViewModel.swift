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
        return "points_history_title".localized
    }
    
    var description: String {
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
    
    func brandHeaderWasTapped() {
        let title: String = membershipCard.membershipPlan?.account?.planNameCard ?? ""
        let description: String = membershipCard.membershipPlan?.account?.planDescription ?? ""
        
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
