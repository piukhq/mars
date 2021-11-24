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
    case lpcLoginRequired
    case lpcBalance(formattedTitle: String?, lastCheckedDate: Date?)
    
    var imageName: String {
        switch self {
        case .loginUnavailable:
            return Asset.lcdModuleIconsPointsInactive.name
        case .plrTransactions, .aboutMembership, .pllTransactions, .lpcBalance:
            return Asset.lcdModuleIconsPointsActive.name
        case .pending:
            return Asset.lcdModuleIconsPointsLoginPending.name
        case .signUp, .patchGhostCard, .loginChanges, .registerGhostCard, .noReasonCode, .lpcLoginRequired:
            return Asset.lcdModuleIconsPointsLogin.name
        case .unlinkable:
            return Asset.lcdModuleIconsLinkInactive.name
        case .genericError:
            return Asset.lcdModuleIconsLinkError.name
        case .pll:
            return Asset.lcdModuleIconsLinkActive.name
        case .pllNoPaymentCards, .pllError:
            return Asset.lcdModuleIconsLinkError.name
        }
    }
    
    var titleText: String {
        switch self {
        case .loginUnavailable:
            return L10n.historyTitle
        case .plrTransactions:
            return L10n.plrLcdPointsModuleAuthTitle
        case .aboutMembership:
            return L10n.plrLcdPointsModuleTitle
        case .pllTransactions(_, let formattedTitle, _):
            return formattedTitle ?? ""
        case .pending:
            return L10n.pendingTitle
        case .signUp:
            return L10n.signUpFailedTitle
        case .patchGhostCard:
            return L10n.registerGcTitle
        case .loginChanges(let type, let status, let reasonCode):
            switch (type, status, reasonCode) {
            case (.points, _, .accountAlreadyExists):
                return L10n.pointsModuleAccountExistsStatus
            case (.points, _, _):
                return L10n.pointsModuleRetryLogInStatus
            case (.link, .unauthorised, _):
                return L10n.logInTitle
            case (.link, .failed, _):
                return L10n.logInFailedTitle
            default: return ""
            }
        case .registerGhostCard:
            return L10n.registrationFailedTitle
        case .noReasonCode:
            return L10n.errorTitle
        case .unlinkable:
            return L10n.cardLinkingStatus
        case .genericError:
            return L10n.linkModuleErrorTitle
        case .pll:
            return L10n.cardLinkedStatus
        case .pllNoPaymentCards, .pllError:
            return L10n.cardLinkStatus
        case .lpcLoginRequired:
            return L10n.loginTitle
        case .lpcBalance(let formattedTitle, _):
            return formattedTitle ?? ""
        }
    }
    
    var subtitleText: String {
        switch self {
        case .loginUnavailable:
            return L10n.notAvailableTitle
        case .plrTransactions:
            return L10n.pointsModuleViewHistoryMessage
        case .aboutMembership:
            return L10n.plrLcdPointsModuleDescription
        case .pllTransactions(let transactionsAvailable, _, let lastChecked):
            if transactionsAvailable == true {
                return L10n.pointsModuleViewHistoryMessage
            } else {
                return "\(L10n.pointsModuleLastChecked) \(lastChecked ?? "")"
            }
        case .pending:
            return L10n.pleaseWaitTitle
        case .patchGhostCard(let type):
            switch type {
            case .points:
                return L10n.pointsModuleToSeeHistory
            case .link:
                return L10n.pleaseTryAgainTitle
            }
        case .loginChanges(let type, let status, let reasonCode):
            switch (type, status, reasonCode) {
            case (.points, _, .accountAlreadyExists):
                return L10n.pointsModuleLogIn
            case (.points, _, _):
                return L10n.pointsModuleToSeeHistory
            case (.link, .unauthorised, _):
                return L10n.linkModuleToLinkToCardsMessage
            case (.link, .failed, _):
                return L10n.pleaseTryAgainTitle
            default:
                return ""
            }
        case .registerGhostCard, .noReasonCode, .signUp:
            return L10n.pleaseTryAgainTitle
        case .unlinkable:
            return L10n.notAvailableTitle
        case .genericError:
            return L10n.errorTitle
        case .pll(let linkedPaymentCards, let paymentCards):
            let linkedPaymentCardsCount = linkedPaymentCards?.count ?? 0
            let paymentCardsCount = paymentCards?.count ?? 0
            return paymentCards?.isEmpty == true ? L10n.linkModuleToNumberOfPaymentCardMessage(linkedPaymentCardsCount, paymentCardsCount) : L10n.linkModuleToNumberOfPaymentCardsMessage(linkedPaymentCardsCount, paymentCardsCount)
        case .pllNoPaymentCards, .pllError:
            return L10n.linkModuleToPaymentCardsMessage
        case .lpcLoginRequired:
            return L10n.pointsModuleToSeeHistory
        case .lpcBalance(_, let lastCheckedDate):
            let lastCheckedString = lastCheckedDate?.timeAgoString(short: true) ?? ""
            return "\(L10n.pointsModuleLastChecked) \(lastCheckedString)"
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
        case .pllTransactions, .lpcBalance:
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
        case .lpcLoginRequired:
            return "lpcLoginRequired"
        }
    }
}
