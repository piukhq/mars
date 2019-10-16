//
//  WalletPromptFactory.swift
//  binkapp
//
//  Created by Nick Farrant on 16/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

final class WalletPromptFactory {
    enum WalletType {
        case loyalty
        case payment
    }

    static func makeWalletPrompts(forWallet walletType: WalletType) -> [WalletPrompt] {
        var walletPrompts: [WalletPrompt] = []

        if walletType == .loyalty {
            guard let plans = Current.wallet.membershipPlans else {
                return walletPrompts
            }

            // join cards
            let sortedPlans = plans.sorted(by: { (firstPlan, secondPlan) -> Bool in
                firstPlan.account?.companyName ?? "" < secondPlan.account?.companyName ?? ""
            })
            sortedPlans.filter({ $0.featureSet?.planCardType == .link }).forEach { plan in
                if shouldShowJoinCard(forMembershipPlan: plan) {
                    walletPrompts.append(WalletPrompt(type: .loyaltyJoin(membershipPlan: plan)))
                }
            }

            // add payment cards prompt
            if shouldShowAddPaymentCard() {
                walletPrompts.append(WalletPrompt(type: .addPaymentCards))
            }
        }

        return walletPrompts
    }

    static private func shouldShowJoinCard(forMembershipPlan plan: CD_MembershipPlan) -> Bool {
        guard let membershipCards = Current.wallet.membershipCards else {
            return false
        }

        var planExistsInWallet = false
        membershipCards.forEach {
            if plan == $0.membershipPlan {
                planExistsInWallet = true
            }
        }

        let hasBeenDismissed = Current.userDefaults.bool(forKey: WalletPrompt.userDefaultsDismissKey(forType: .loyaltyJoin(membershipPlan: plan)))
        return !hasBeenDismissed && !planExistsInWallet
    }

    static private func shouldShowAddPaymentCard() -> Bool {
        return !Current.userDefaults.bool(forKey: WalletPrompt.userDefaultsDismissKey(forType: .addPaymentCards))
    }
}
