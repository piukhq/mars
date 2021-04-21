//
//  BinkModuleType.swift
//  binkapp
//
//  Created by Nick Farrant on 19/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

enum ModuleType {
    case points(membershipCard: CD_MembershipCard)
    case link(membershipCard: CD_MembershipCard, paymentCards: [CD_PaymentCard]?)
}

enum ModuleState: Equatable {
    static func == (lhs: ModuleState, rhs: ModuleState) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    case loginUnavailable
    case plrTransactions
    case aboutMembership
    case pllTransactions(transactionsAvailable: Bool?, formattedTitle: String?, lastChecked: String?)
    case pending
    case signUp
    case patchGhostCard(type: ModuleType)
    case loginChanges(type: ModuleType, status: MembershipCardStatus?, reasonCode: ReasonCode?)
    case registerGhostCard
    case noReasonCode
    case unlinkable
    case genericError
    case pll(linkedPaymentCards: [CD_PaymentCard]?, paymentCards: [CD_PaymentCard]?)
    case pllNoPaymentCards
    case pllError
    
    var imageName: String {
        switch self {
        case .loginUnavailable:
            return "lcdModuleIconsPointsInactive"
        case .plrTransactions:
            return "lcdModuleIconsPointsActive"
        case .aboutMembership:
            return "lcdModuleIconsPointsActive"
        case .pllTransactions:
            return "lcdModuleIconsPointsActive"
        case .pending:
            return "lcdModuleIconsPointsLoginPending"
        case .signUp:
            return "lcdModuleIconsPointsLogin"
        case .patchGhostCard:
            return "lcdModuleIconsPointsLogin"
        case .loginChanges:
            return "lcdModuleIconsPointsLogin"
        case .registerGhostCard:
            return "lcdModuleIconsPointsLogin"
        case .noReasonCode:
            return "lcdModuleIconsPointsLogin"
        case .unlinkable:
            return "lcdModuleIconsLinkInactive"
        case .genericError:
            return "lcdModuleIconsLinkError"
        case .pll:
            return "lcdModuleIconsLinkActive"
        case .pllNoPaymentCards:
            return "lcdModuleIconsLinkError"
        case .pllError:
            return "lcdModuleIconsLinkError"
        }
    }
    
    var titleText: String {
        switch self {
        case .loginUnavailable:
            return "history_title".localized
        case .plrTransactions:
            return "plr_lcd_points_module_auth_title".localized
        case .aboutMembership:
            return "plr_lcd_points_module_title".localized
        case .pllTransactions(_, let formattedTitle, _):
            return formattedTitle ?? ""
        case .pending:
            return "pending_title".localized
        case .signUp:
            return "sign_up_failed_title".localized
        case .patchGhostCard:
            return "register_gc_title".localized
        case .loginChanges(let type, let status, let reasonCode):
            switch (type, status, reasonCode) {
            case (.points, _, .accountAlreadyExists):
                return "points_module_account_exists_status".localized
            case (.points, _, _):
                return "points_module_retry_log_in_status".localized
            case (.link, .unauthorised, _):
                return "log_in_title".localized
            case (.link, .failed, _):
                return "log_in_failed_title".localized
            default: return ""
            }
        case .registerGhostCard:
            return "registration_failed_title".localized
        case .noReasonCode:
            return "error_title".localized
        case .unlinkable:
            return "card_linking_status".localized
        case .genericError:
            return "link_module_error_title".localized
        case .pll:
            return "card_linked_status".localized
        case .pllNoPaymentCards:
            return "card_link_status".localized
        case .pllError:
            return "card_link_status".localized
        }
    }
    
    var subtitleText: String {
        switch self {
        case .loginUnavailable:
            return "not_available_title".localized
        case .plrTransactions:
            return "points_module_view_history_message".localized
        case .aboutMembership:
            return "plr_lcd_points_module_description".localized
        case .pllTransactions(let transactionsAvailable, _, let lastChecked):
            if transactionsAvailable == true {
                return "points_module_view_history_message".localized
            } else {
                return "\("points_module_last_checked".localized) \(lastChecked ?? "")"
            }
        case .pending:
            return "please_wait_title".localized
        case .signUp:
            return "please_try_again_title".localized
        case .patchGhostCard(let type):
            switch type {
            case .points:
                return "points_module_to_see_history".localized
            case .link:
                return "please_try_again_title".localized
            }
        case .loginChanges(let type, let status, let reasonCode):
            switch (type, status, reasonCode) {
            case (.points, _, .accountAlreadyExists):
                return "points_module_log_in".localized
            case (.points, _, _):
                return "points_module_to_see_history".localized
            case (.link, .unauthorised, _):
                return "link_module_to_link_to_cards_message".localized
            case (.link, .failed, _):
                return "please_try_again_title".localized
            default:
                return ""
            }
        case .registerGhostCard:
            return "please_try_again_title".localized
        case .noReasonCode:
            return "please_try_again_title".localized
        case .unlinkable:
            return "not_available_title".localized
        case .genericError:
            return "error_title".localized
        case .pll(let linkedPaymentCards, let paymentCards):
            return String(format: paymentCards?.isEmpty == true ? "link_module_to_number_of_payment_card_message".localized : "link_module_to_number_of_payment_cards_message".localized, linkedPaymentCards?.count ?? 0, paymentCards?.count ?? 0)
        case .pllNoPaymentCards:
            return "link_module_to_payment_cards_message".localized
        case .pllError:
            return "link_module_to_payment_cards_message".localized
        }
    }
    
    var identifier: String {
        switch self {
        case .loginUnavailable:
            return "loginUnavailable"
        case .plrTransactions:
            return "plrTransactions"
        case .aboutMembership:
            return "aboutMembership"
        case .pllTransactions:
            return "pllTransactions"
        case .pending:
            return "pending"
        case .signUp:
            return "signUp"
        case .patchGhostCard:
            return "patchGhostCard"
        case .loginChanges:
            return "loginChanges"
        case .registerGhostCard:
            return "registerGhostCard"
        case .noReasonCode:
            return "noReasonCode"
        case .unlinkable:
            return "unlinkable"
        case .genericError:
            return "genericError"
        case .pll:
            return "pll"
        case .pllNoPaymentCards:
            return "pllNoPaymentCards"
        case .pllError:
            return "pllError"
        }
    }
}
