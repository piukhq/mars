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
        case .see:
            return "wallet_prompt_see_title".localized
        case .store:
            return "wallet_prompt_store_title".localized
        }
    }

    var body: String {
        switch self {
        case .addPaymentCards:
            return "wallet_prompt_payment".localized
        case .link:
            return "wallet_prompt_link_body".localized
        case .see:
            return "wallet_prompt_see_body".localized
        case .store:
            return "wallet_prompt_store_body".localized
        }
    }

    var userDefaultsDismissKey: String {
        var userDefaultsDismiss = ""
        
        // Let these be on a per user basis
        if let email = Current.userManager.currentEmailAddress {
            userDefaultsDismiss += "\(email)_"
        }
        
        switch self {
        case .addPaymentCards:
            userDefaultsDismiss += "add_payment_card_prompt_was_dismissed"
        default:
            break
        }
        
        return userDefaultsDismiss
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
            return UIDevice.current.iPhoneSE ? 4 : 5
        default:
            return 0
        }
    }
    
    var maxNumberOfPlansToDisplay: Int {
        switch self {
        case .link:
            return 4
        case .see, .store:
            return UIDevice.current.iPhoneSE ? 8 : 10
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
    var userDefaultsDismissKey: String { get }
    var membershipPlans: [CD_MembershipPlan]? { get }
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

    static func userDefaultsDismissKey(forType type: WalletPromptType) -> String {
        return type.userDefaultsDismissKey
    }
}
