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
    case addPaymentCards
    case link(plans: [CD_MembershipPlan])
    case see(plans: [CD_MembershipPlan])
    case store(plans: [CD_MembershipPlan])

    var title: String {
        switch self {
        case .addPaymentCards:
            return "Add your payment cards"
        case .link:
            return "wallet_prompt_link_title".localized
        default :
            return ""
        }
    }

    var body: String {
        switch self {
        case .addPaymentCards:
            return "wallet_prompt_payment".localized
        case .link:
            return "wallet_prompt_link_body".localized
        default:
            return ""
        }
    }

    var membershipPlans: [CD_MembershipPlan]? {
        switch self {
        case .link(let plans):
            return plans
        case .addPaymentCards:
            return nil
        case .see(plans: let plans):
            return plans
        case .store(plans: let plans):
            return plans
        }
    }

    var numberOfRows: CGFloat {
        switch self {
        case .link(let plans):
            return plans.count > 2 ? 2 : 1
        default:
            return 0
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
    var membershipPlans: [CD_MembershipPlan]? { get }
    var iconImageName: String? { get }
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

    var membershipPlans: [CD_MembershipPlan]? {
        return type.membershipPlans
    }
    
    var numberOfRows: CGFloat {
        return type.numberOfRows
    }

    var iconImageName: String? {
        return type.iconImageName
    }
}
