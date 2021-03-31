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
            guard let plans = Current.wallet.membershipPlans, let membershipCards = Current.wallet.membershipCards else {
                return walletPrompts
            }
            
            if !membershipCards.contains(where: { $0.membershipPlan?.featureSet?.planCardType == .link }) {
                /// Get PLL plans and sort by ID
                let pllPlans = plans.filter({ $0.featureSet?.planCardType == .link })
                var sortedPlans = pllPlans.sorted(by: {(firstPlan, secondPlan) -> Bool in
                    firstPlan.account?.id ?? "" > secondPlan.account?.id ?? ""
                })
                
                #if DEBUG
                sortedPlans = adjustDebugCellCount(totalNumberOfPlans: Current.wallet.linkPromptDebugCellCount, sortedPlans: &sortedPlans)
                #endif
            
                walletPrompts.append(WalletPrompt(type: .link(plans: sortedPlans)))
            }
        }

        /// Add payment card prompt to payment wallet only
        if walletType == .payment {
            walletPrompts.append(WalletPrompt(type: .addPaymentCards))
        }

        return walletPrompts
    }
}

// Debugging methods
extension WalletPromptFactory {
    static private func adjustDebugCellCount(totalNumberOfPlans: Int?, sortedPlans: inout [CD_MembershipPlan]) -> [CD_MembershipPlan] {
        guard let plans = Current.wallet.membershipPlans else { return [] }
        
        if let totalNumberOfPlans = totalNumberOfPlans {
            let numberToAddOrRemove = sortedPlans.count - totalNumberOfPlans
            
            if numberToAddOrRemove < 0 {
                /// If negative, add that many plans onto sorted plans
                let plansToAppend = plans.prefix(abs(numberToAddOrRemove))
                sortedPlans.append(contentsOf: plansToAppend)
            } else {
                sortedPlans.removeLast(numberToAddOrRemove)
            }
        }
        return sortedPlans
    }
}
