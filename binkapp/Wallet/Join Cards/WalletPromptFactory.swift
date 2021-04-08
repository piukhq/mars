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
            guard var plans = Current.wallet.membershipPlans, let membershipCards = Current.wallet.membershipCards else {
                return walletPrompts
            }

            plans = plans.sorted(by: { $0.account?.id.localizedStandardCompare($1.account?.id ?? "") == .orderedDescending })
            
            // PLL
            if !membershipCards.contains(where: { $0.membershipPlan?.featureSet?.planCardType == .link }) {
                var pllPlans = plans.filter({ $0.featureSet?.planCardType == .link })
                
                #if DEBUG
                pllPlans = adjustDebugCellCount(totalNumberOfPlans: Current.wallet.linkPromptDebugCellCount, sortedPlans: &pllPlans)
                #endif
                
                walletPrompts.append(WalletPrompt(type: .link(plans: pllPlans)))
            }
            
            // See
            if !membershipCards.contains(where: { $0.membershipPlan?.featureSet?.planCardType == .view }) {
                let plansEnabledOnRemoteConfig = Current.pointsScrapingManager.agents.filter { Current.pointsScrapingManager.planIdIsWebScrapable($0.membershipPlanId) }
                if !plansEnabledOnRemoteConfig.isEmpty {
                    let seePlans = plans.filter { $0.featureSet?.planCardType == .view }
                    var liveSeePlans = seePlans.filter { plan -> Bool in
                        return plansEnabledOnRemoteConfig.contains(where: { $0.membershipPlanId == Int(plan.id) })
                    }
                    
                    #if DEBUG
                    liveSeePlans = adjustDebugCellCount(totalNumberOfPlans: Current.wallet.seePromptDebugCellCount, sortedPlans: &liveSeePlans)
                    #endif
                    
                    walletPrompts.append(WalletPrompt(type: .see(plans: liveSeePlans)))
                }
            }
            
            
            // Store
            if !membershipCards.contains(where: { $0.membershipPlan?.featureSet?.planCardType == .store }) {
                var storePlans = plans.filter { $0.featureSet?.planCardType == .store }
                
                #if DEBUG
                storePlans = adjustDebugCellCount(totalNumberOfPlans: Current.wallet.storePromptDebugCellCount, sortedPlans: &storePlans)
                #endif
                
                walletPrompts.append(WalletPrompt(type: .store(plans: storePlans)))
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
