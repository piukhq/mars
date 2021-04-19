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
    
    case login
    case loginChanges(type: ModuleType?, status: MembershipCardStatus?)
    case transactions(transactionsAvailable: Bool, lastCheckedString: String?)
    case pending
    case loginUnavailable
    case signUp
    case patchGhostCard(type: ModuleType?)
    case registerGhostCard
    case pllEmpty
    case pll
    case unlinkable
    case genericError
    case aboutMembership
    case noReasonCode
    
    var imageName: String {
        switch self {
        case .login:
            return ""
        case .loginChanges:
            return "lcdModuleIconsPointsLogin"
        case .transactions:
            return "lcdModuleIconsPointsActive"
        case .pending:
            return "lcdModuleIconsPointsLoginPending"
        case .loginUnavailable:
            return "lcdModuleIconsPointsInactive"
        case .signUp:
            return "lcdModuleIconsPointsLogin"
        case .patchGhostCard:
            return "lcdModuleIconsPointsLogin"
        case .registerGhostCard:
            return "lcdModuleIconsPointsLogin"
        case .pllEmpty:
            return "lcdModuleIconsLinkError"
        case .pll:
            return "lcdModuleIconsLinkActive"
        case .unlinkable:
            return "lcdModuleIconsLinkInactive"
        case .genericError:
            return "lcdModuleIconsLinkError"
        case .aboutMembership:
            return "lcdModuleIconsPointsActive"
        case .noReasonCode:
            return "lcdModuleIconsPointsLogin"
        }
    }
    
    var titleText: String {
        switch self {
        case .login:
            return ""
        case .loginChanges(let moduleType, _):
            switch moduleType {
            case .points:
                return "points_module_account_exists_status".localized
            case .link:
                return "log_in_title".localized
            default: return ""
            }
        case .transactions:
            return "plr_lcd_points_module_auth_title".localized
        case .pending:
            return "pending_title".localized
        case .loginUnavailable:
            return "history_title".localized
        case .signUp:
            return "sign_up_failed_title".localized
        case .patchGhostCard:
            return "register_gc_title".localized
        case .registerGhostCard:
            return "registration_failed_title".localized
        case .pllEmpty:
            return "card_link_status".localized
        case .pll:
            return "card_linked_status".localized
        case .unlinkable:
            return "card_linking_status".localized
        case .genericError:
            return "link_module_error_title".localized
        case .aboutMembership:
            return "plr_lcd_points_module_title".localized
        case .noReasonCode:
            return "error_title".localized
        }
    }
    
    var subtitleText: String {
        switch self {
        case .login:
            return ""
        case .loginChanges(let moduleType, let status):
            switch (moduleType, status) {
            case (.points, _):
                return "points_module_log_in".localized
            case (.link, .failed):
                return "please_try_again_title".localized
            case (.link, _):
                return "link_module_to_link_to_cards_message".localized
            default: return ""
            }
        case .transactions(let transactionsAvailable, let lastChecked):
            switch transactionsAvailable {
            case true:
                return "points_module_view_history_message".localized
            case false:
                return "points_module_last_checked".localized + " \(lastChecked ?? "")"
            }
        case .pending:
            return "please_wait_title".localized
        case .loginUnavailable:
            return "not_available_title".localized
        case .signUp:
            return "please_try_again_title".localized
        case .patchGhostCard(let moduleType):
            switch moduleType {
            case .points:
                return "points_module_to_see_history".localized
            case .link:
                return "please_try_again_title".localized
            default: return ""
            }
        case .registerGhostCard:
            return "please_try_again_title".localized
        case .pllEmpty:
            return "link_module_to_payment_cards_message".localized
        case .pll:
            return ""
        case .unlinkable:
            return "not_available_title".localized
        case .genericError:
            return "error_title".localized
        case .aboutMembership:
            return "plr_lcd_points_module_description".localized
        case .noReasonCode:
            return "please_try_again_title".localized
        }
    }
    
    var identifier: String {
        switch self {
        case .login:
            return "login"
        case .loginChanges:
            return "loginChanges"
        case .transactions:
            return "transactions"
        case .pending:
            return "pending"
        case .loginUnavailable:
            return "loginUnavailable"
        case .signUp:
            return "signUp"
        case .patchGhostCard:
            return "patchGhostCard"
        case .registerGhostCard:
            return "registerGhostCard"
        case .pllEmpty:
            return "pllEmpty"
        case .pll:
            return "pll"
        case .unlinkable:
            return "unlinkable"
        case .genericError:
            return "genericError"
        case .aboutMembership:
            return "aboutMembership"
        case .noReasonCode:
            return "noReasonCode"
        }
    }
}
