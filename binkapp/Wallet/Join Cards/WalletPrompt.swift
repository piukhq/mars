//
//  WalletPrompt.swift
//  binkapp
//
//  Created by Nick Farrant on 16/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CardScan

enum WalletPromptType {
    case loyaltyJoin(membershipPlan: CD_MembershipPlan)
    case addPaymentCards(scanDelegate: ScanDelegate?)

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
            return "wallet_prompt_loyalty".localized
        case .addPaymentCards:
            return "wallet_prompt_payment".localized
        }
    }

    var userDefaultsDismissKey: String {
        
        var userDefaultsDismiss = ""
        
        // Let these be on a per user basis
        if let email = Current.userManager.currentEmailAddress {
            userDefaultsDismiss += "\(email)_"
        }
        
        switch self {
        case .loyaltyJoin(let plan):
            userDefaultsDismiss += "join_card_\(plan.account?.planName ?? "")_was_dismissed"
        case .addPaymentCards:
            userDefaultsDismiss += "add_payment_card_prompt_was_dismissed"
        }
        
        return userDefaultsDismiss
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
}

protocol WalletPromptProtocol {
    var title: String { get }
    var body: String { get }
    var userDefaultsDismissKey: String { get }
    var membershipPlan: CD_MembershipPlan? { get }
    var iconImageName: String? { get }
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

    static func userDefaultsDismissKey(forType type: WalletPromptType) -> String {
        return type.userDefaultsDismissKey
    }
}
