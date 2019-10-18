//
//  WalletPrompt.swift
//  binkapp
//
//  Created by Nick Farrant on 16/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

enum WalletPromptType {
    case loyaltyJoin(membershipPlan: CD_MembershipPlan)
    case addPaymentCards

    var title: String {
        switch self {
        case .loyaltyJoin(let plan):
            return plan.account?.planName ?? ""
        case .addPaymentCards:
            return "Add your payment cards"
        }
    }

    var body: String {
        switch self {
        case .loyaltyJoin:
            return "Link this card to your payment cards to automatically collect rewards."
        case .addPaymentCards:
            return "You will need to add at least one to collect rewards automatically."
        }
    }

    var userDefaultsDismissKey: String {
        switch self {
        case .loyaltyJoin(let plan):
            return "join_card_\(plan.account?.planName ?? "")_was_dismissed"
        case .addPaymentCards:
            return "add_payment_card_prompt_was_dismissed"
        }
    }

    var membershipPlan: CD_MembershipPlan? {
        switch self {
        case .loyaltyJoin(let plan):
            return plan
        case .addPaymentCards:
            return nil
        }
    }

    var iconImageName: String? {
        switch self {
        case .addPaymentCards:
            return "payment"
        default:
            return nil
        }
    }

    var iconImageUrl: URL? {
        switch self {
        case .loyaltyJoin(let plan):
            return URL(string: plan.firstIconImage()?.url ?? "")
        default:
            return nil
        }
    }
}

protocol WalletPromptProtocol {
    var title: String { get }
    var body: String { get }
    var userDefaultsDismissKey: String { get }
    var membershipPlan: CD_MembershipPlan? { get }
    var iconImageName: String? { get }
    var iconImageUrl: URL? { get }
    static func userDefaultsDismissKey(forType type: WalletPromptType) -> String
    init(type: WalletPromptType)
}

class WalletPrompt: WalletPromptProtocol {
    let type: WalletPromptType

    required init(type: WalletPromptType) {
        self.type = type
    }

    var title: String {
        return type.title
    }

    var body: String {
        return type.body
    }

    var userDefaultsDismissKey: String {
        return type.userDefaultsDismissKey
    }

    var membershipPlan: CD_MembershipPlan? {
        return type.membershipPlan
    }

    var iconImageName: String? {
        return type.iconImageName
    }

    var iconImageUrl: URL? {
        return type.iconImageUrl
    }

    static func userDefaultsDismissKey(forType type: WalletPromptType) -> String {
        return type.userDefaultsDismissKey
    }
}
