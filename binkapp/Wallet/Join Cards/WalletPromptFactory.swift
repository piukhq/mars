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

        // TODO: Reinstate this: >>>>>>>>>>>>>
//        guard Current.wallet.shouldDisplayWalletPrompts == true else {
//            return walletPrompts
//        }
        // <<<<<<<<<<<<<<<<<<<<<<<

        if walletType == .loyalty {
//            guard let plans = Current.wallet.membershipPlans else {
//                return walletPrompts
//            }
//
//            // join cards
//            let sortedPlans = plans.sorted(by: { (firstPlan, secondPlan) -> Bool in
//                firstPlan.account?.companyName ?? "" < secondPlan.account?.companyName ?? ""
//            })
//            sortedPlans.filter({ $0.featureSet?.planCardType == .link }).forEach { plan in
//                if shouldShowJoinCard(forMembershipPlan: plan) {
//                    walletPrompts.append(WalletPrompt(type: .loyaltyJoin(membershipPlan: plan)))
//                }
//            }
            
            // Check if there are any PLL or PLR cards, if none, return linkwallet prompt
            walletPrompts.append(WalletPrompt(type: .link))
            
            
            // Check for see and store cards and return one of those types if none
            
        }

        // add payment cards prompt
        if walletType == .payment && shouldShowAddPaymentCard() {
            walletPrompts.append(WalletPrompt(type: .addPaymentCards))
        }

        return walletPrompts
    }

//    static private func shouldShowJoinCard(forMembershipPlan plan: CD_MembershipPlan) -> Bool {
//        guard let membershipCards = Current.wallet.membershipCards else {
//            return false
//        }
//
//        var planExistsInWallet = false
//        membershipCards.forEach {
//            if plan == $0.membershipPlan {
//                planExistsInWallet = true
//            }
//        }
//
//        let hasBeenDismissed = Current.userDefaults.bool(forKey: WalletPrompt.userDefaultsDismissKey(forType: .loyaltyJoin(membershipPlan: plan)))
//        return !hasBeenDismissed && !planExistsInWallet
//    }

    static private func shouldShowAddPaymentCard() -> Bool {
        // We pass nil as the scan delegate as the receiver doesn't care about the delegate in order to return the key
        return !Current.userDefaults.bool(forKey: WalletPrompt.userDefaultsDismissKey(forType: .addPaymentCards)) && !Current.wallet.hasPaymentCards
    }
}
