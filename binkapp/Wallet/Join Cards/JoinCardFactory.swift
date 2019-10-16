//
//  JoinCardFactory.swift
//  binkapp
//
//  Created by Nick Farrant on 16/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

final class JoinCardFactory {
    enum WalletType {
        case loyalty
        case payment
    }

    static func makeJoinCards(forWallet walletType: WalletType) -> [JoinCard] {
        var joinCards: [JoinCard] = []

        if walletType == .loyalty {
            guard let plans = Current.wallet.membershipPlans else {
                return joinCards
            }

            plans.filter({ $0.featureSet?.planCardType == .link }).forEach { plan in
                if shouldShowJoinCard(forMembershipPlan: plan) {
                    joinCards.append(JoinCard(membershipPlan: plan))
                }
            }
        }

        return joinCards
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

        let planJoinCardHasBeenDismissed = UserDefaults.standard.bool(forKey: JoinCard.userDefaultsKey(forPlan: plan))
        return !planJoinCardHasBeenDismissed && !planExistsInWallet
    }
}
