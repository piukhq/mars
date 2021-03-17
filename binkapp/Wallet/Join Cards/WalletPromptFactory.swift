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
            
            // PLL
            if !membershipCards.contains(where: { $0.membershipPlan?.featureSet?.planCardType == .link }) {
                /// Get PLL plans and sort by ID
                let pllPlans = plans.filter({ $0.featureSet?.planCardType == .link })
                var sortedPlans = pllPlans.sorted(by: {(firstPlan, secondPlan) -> Bool in
                    firstPlan.account?.id ?? "" > secondPlan.account?.id ?? ""
                })
                
                sortedPlans = addOrRemovePlans(totalNumberOfPlans: Current.numberOfLinkPromptCells, sortedPlans: &sortedPlans) ///  For debug testing
                walletPrompts.append(WalletPrompt(type: .link(plans: sortedPlans)))
            }
            
            // See
            if !membershipCards.contains(where: { $0.membershipPlan?.featureSet?.planCardType == .view }) {
                let plansEnabledOnRemoteConfig = Current.pointsScrapingManager.agents.filter { Current.pointsScrapingManager.agentEnabled($0) }
                let seePlans = plans.filter { $0.featureSet?.planCardType == .view }
                let liveSeePlans = seePlans.filter { plan -> Bool in
                    return plansEnabledOnRemoteConfig.contains(where: { $0.membershipPlanId == Int(plan.id) })
                }
                
                walletPrompts.append(WalletPrompt(type: .see(plans: liveSeePlans)))
            }
            
            
            // Store
            if !membershipCards.contains(where: { $0.membershipPlan?.featureSet?.planCardType == .store }) {

            }
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
    
    fileprivate static func addOrRemovePlans(totalNumberOfPlans: Int?, sortedPlans: inout [CD_MembershipPlan]) -> [CD_MembershipPlan] {
        guard let plans = Current.wallet.membershipPlans else { return [] }
        
        if let totalNumberOfPlans = totalNumberOfPlans {
            let numberToAddOrRemove = sortedPlans.count - totalNumberOfPlans
            
            if numberToAddOrRemove < 0 {
                // If negative, add that many plans onto sorted plans
                let plansToAppend = plans.prefix(abs(numberToAddOrRemove))
                sortedPlans.append(contentsOf: plansToAppend)
            } else {
                sortedPlans.removeLast(numberToAddOrRemove)
            }
        }
        return sortedPlans
    }
}
