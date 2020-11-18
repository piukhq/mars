//
//  WalletPromptMock.swift
//  binkapp
//
//  Created by Sean Williams on 18/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import CardScan

enum WalletPromptTypeMock {
    case loyaltyJoin(membershipPlan: MembershipPlanModel)
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

    var membershipPlan: MembershipPlanModel? {
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

protocol WalletPromptProtocolMock {
    var title: String { get }
    var body: String { get }
    var userDefaultsDismissKey: String { get }
    var membershipPlan: MembershipPlanModel? { get }
    var iconImageName: String? { get }
    static func userDefaultsDismissKey(forType type: WalletPromptTypeMock) -> String
    init(type: WalletPromptTypeMock)
}

class WalletPromptMock: WalletPromptProtocolMock {
    let type: WalletPromptTypeMock

    required init(type: WalletPromptTypeMock) {
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

    var membershipPlan: MembershipPlanModel? {
        return type.membershipPlan
    }

    var iconImageName: String? {
        return type.iconImageName
    }

    static func userDefaultsDismissKey(forType type: WalletPromptTypeMock) -> String {
        return type.userDefaultsDismissKey
    }
}
