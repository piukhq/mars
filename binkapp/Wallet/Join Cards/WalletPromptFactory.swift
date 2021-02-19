//
//  WalletPromptFactory.swift
//  binkapp
//
//  Created by Nick Farrant on 16/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CardScan

enum WalletPromptFactory {
    enum WalletType {
        case loyalty
        case payment
    }

    static func makeWalletPrompts(forWallet walletType: WalletType) -> [WalletPrompt] {
        var walletPrompts: [WalletPrompt] = []

        guard Current.wallet.shouldDisplayWalletPrompts == true else {
            return walletPrompts
        }

        if walletType == .loyalty {
            guard let plans = Current.wallet.membershipPlans, let membershipCards = Current.wallet.membershipCards, !membershipCards.contains(where: { $0.membershipPlan?.featureSet?.planCardType == .link }) else {
                return walletPrompts
            }
            
            /// Get PLL plans and sort by ID
            let pllPlans = plans.filter({ $0.featureSet?.planCardType == .link })
            var sortedPlans = pllPlans.sorted(by: {(firstPlan, secondPlan) -> Bool in
                firstPlan.account?.id ?? "" > secondPlan.account?.id ?? ""
            })
            
            /// Remove after testing is complete >>>>>>>>>>>>>>
            if let numberOfCells = Current.numberOfPromptCells {
                let numberOfPlansToRemove = sortedPlans.count - numberOfCells
                
                if numberOfPlansToRemove < 0 {
                    // If negative, add that many plans onto sorted plans
                    let plansToAppend = plans.prefix(abs(numberOfPlansToRemove))
                    sortedPlans.append(contentsOf: plansToAppend)
                } else {
                    sortedPlans.removeLast(numberOfPlansToRemove)
                }
            }
            /// <<<<<<<<<<<<<<<<<<<
            
            walletPrompts.append(WalletPrompt(type: .link(plans: sortedPlans)))

            // TODO: Check for see and store cards and return one of those types if none
        }

        /// Add payment card prompt to payment wallet only
        if walletType == .payment && shouldShowAddPaymentCard() {
            walletPrompts.append(WalletPrompt(type: .addPaymentCards))
        }

        return walletPrompts
    }

    static private func shouldShowAddPaymentCard() -> Bool {
        // We pass nil as the scan delegate as the receiver doesn't care about the delegate in order to return the key
        return !Current.userDefaults.bool(forKey: WalletPrompt.userDefaultsDismissKey(forType: .addPaymentCards)) && !Current.wallet.hasPaymentCards
    }
}
