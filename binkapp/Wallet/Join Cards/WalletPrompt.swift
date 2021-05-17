//
//  WalletPrompt.swift
//  binkapp
//
//  Created by Nick Farrant on 16/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CardScan

enum WalletPromptType: Hashable {
    case addPaymentCards
    case link(plans: [CD_MembershipPlan])
    case see(plans: [CD_MembershipPlan])
    case store(plans: [CD_MembershipPlan])

    var title: String {
        switch self {
        case .addPaymentCards:
            return "Add your payment cards"
        case .link:
            return L10n.walletPromptLinkTitle
        case .see:
            return L10n.walletPromptSeeTitle
        case .store:
            return L10n.walletPromptStoreTitle
        }
    }

    var body: String {
        switch self {
        case .addPaymentCards:
            return L10n.walletPromptPayment
        case .link:
            return L10n.walletPromptLinkBody
        case .see:
            return L10n.walletPromptSeeBody
        case .store:
            return L10n.walletPromptStoreBody
        }
    }

    var membershipPlans: [CD_MembershipPlan]? {
        switch self {
        case .link(let plans), .see(let plans), .store(let plans):
            return plans
        case .addPaymentCards:
            return nil
        }
    }

    var numberOfRows: CGFloat {
        switch self {
        case .link(let plans):
            return plans.count > 2 ? 2 : 1
        case .see(let plans), .store(let plans):
            return plans.count > maxNumberOfPlansToDisplay / 2 ? 2 : 1
        default:
            return 0
        }
    }
    
    var numberOfItemsPerRow: CGFloat {
        switch self {
        case .link:
            return 2
        case .see, .store:
            return UIDevice.current.isSmallSize ? 4 : 5
        default:
            return 0
        }
    }
    
    var maxNumberOfPlansToDisplay: Int {
        switch self {
        case .link:
            return 4
        case .see, .store:
            return UIDevice.current.isSmallSize ? 8 : 10
        default:
            return 0
        }
    }

    var iconImageName: String? {
        switch self {
        case .addPaymentCards:
            return Asset.payment.name
        default:
            return nil
        }
    }
    
    var index: Int? {
        switch self {
        case .addPaymentCards:
            return nil
        case .link:
            return 0
        case .see:
            return 1
        case .store:
            return 2
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

class WalletPrompt: WalletPromptProtocol, Hashable {
    static func == (lhs: WalletPrompt, rhs: WalletPrompt) -> Bool {
        return lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
    
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
    
    var numberOfItemsPerRow: CGFloat {
        return type.numberOfItemsPerRow
    }

    var iconImageName: String? {
        return type.iconImageName
    }
    
    var maxNumberOfPlansToDisplay: Int {
        return type.maxNumberOfPlansToDisplay
    }
}
