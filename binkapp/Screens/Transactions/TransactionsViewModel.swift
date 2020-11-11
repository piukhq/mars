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

    private var storedMostRecentTransaction: MembershipCardStoredMostRecentTransaction? {
        guard let dictionary = Current.userDefaults.value(forDefaultsKey: .membershipCardMostRecentTransaction(membershipCardId: membershipCard.id)) as? [String: Any] else { return nil }
        return MembershipCardStoredMostRecentTransaction.fromDictionary(dictionary)
    }

    var hasStoredMostRecentTransaction: Bool {
        return storedMostRecentTransaction != nil
    }

    var shouldRequestInAppReview: Bool {
        if let storeMostRecentTransaction = storedMostRecentTransaction {
            return !storeMostRecentTransaction.isMostRecentTransaction(from: transactions)
        } else {
            return false
        }
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
        
        let buttonCompletionBlock = {
            let viewController = ViewControllerFactory.makeWebViewController(urlString: plan.account?.planURL ?? "")
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
        
        let viewController = ViewControllerFactory.makeAboutMembershipPlanViewController(membershipPlan: plan, completion: buttonCompletionBlock)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }

    func storeMostRecentTransaction() {
        guard let timestamp = transactions.first?.timestamp?.intValue else { return }
        let mostRecentTransaction = MembershipCardStoredMostRecentTransaction(membershipCardId: membershipCard.id, timestamp: timestamp)
        Current.userDefaults.set(mostRecentTransaction.toDictionary, forDefaultsKey: .membershipCardMostRecentTransaction(membershipCardId: membershipCard.id))
    }
}
