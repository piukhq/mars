//
//  BinkModuleViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 21/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

class BinkModuleViewModel {
    private let type: ModuleType
    
    init(type: ModuleType) {
        self.type = type
    }
    
    lazy var state: ModuleState = {
        switch type {
        case .points(let membershipCard):
            return pointsState(membershipCard: membershipCard)
        case .link(let membershipCard, let paymentCards):
            return linkState(membershipCard: membershipCard, paymentCards: paymentCards)
        }
    }()
    
    var imageName: String {
        return state.imageName
    }
    
    var titleText: String {
        return state.titleText
    }
    
    var subtitleText: String {
        return state.subtitleText
    }
}

private extension BinkModuleViewModel {
    func pointsState(membershipCard: CD_MembershipCard) -> ModuleState {
        guard let plan = membershipCard.membershipPlan, plan.featureSet?.hasPoints?.boolValue ?? false || plan.featureSet?.transactionsAvailable?.boolValue ?? false else {
            // Points module 1.5
            return .loginUnavailable
        }
        
        switch membershipCard.status?.status {
        case .authorised:
            // PLR
            if plan.isPLR == true {
                if plan.featureSet?.transactionsAvailable?.boolValue == true {
                    return .plrTransactions
                } else {
                    return .aboutMembership
                }
            }

            // Points module 1.1, 1.2
            if let balances = membershipCard.balances.allObjects as? [CD_MembershipCardBalance], let balance = balances.first {
                let transactionsAvailable = plan.featureSet?.transactionsAvailable?.boolValue == true
                let date = Date(timeIntervalSince1970: balance.updatedAt?.doubleValue ?? 0)
                return .pllTransactions(transactionsAvailable: transactionsAvailable, formattedTitle: balance.formattedBalance, lastChecked: date.timeAgoString(short: true))
            } else {
                return .pending
            }
        case .pending:
            return .pending
        case .failed, .unauthorised:
            if let reasonCode = membershipCard.status?.formattedReasonCodes?.first {
                switch reasonCode {
                case .enrolmentDataRejectedByMerchant:
                    // Points module 1.8
                    return .signUp
                case .accountNotRegistered:
                    // Points module 1.x (to be defined)
                    return .patchGhostCard(type: .points(membershipCard: membershipCard))
                case .accountAlreadyExists:
                    // Points module 1.12
                    return .loginChanges(type: .points(membershipCard: membershipCard), status: membershipCard.status?.status, reasonCode: reasonCode)
                case .accountDoesNotExist, .addDataRejectedByMerchant, .NoAuthorizationProvided, .updateFailed, .noAuthorizationRequired, .authorizationDataRejectedByMerchant, .authorizationExpired, .pointsScrapingLoginFailed:
                    
                    // Points module 1.6
                    return .loginChanges(type: .points(membershipCard: membershipCard), status: membershipCard.status?.status, reasonCode: reasonCode)
                default:
                    // Points module 1.10 (need reason codes, set by default)
                    return .registerGhostCard
                }
            } else {
                return .noReasonCode
            }
        default:
            fatalError("Unknown state")
        }
    }
    
    func linkState(membershipCard: CD_MembershipCard, paymentCards: [CD_PaymentCard]?) -> ModuleState {
        guard let plan = membershipCard.membershipPlan else {
            fatalError("Unknown state")
        }

        guard plan.featureSet?.planCardType == .link else {
            switch plan.featureSet?.planCardType {
            case .store, .view:
                // Link module 2.8
                return .unlinkable
            default:
                // Link module 2.4
                return .genericError
            }
        }
        
        switch membershipCard.status?.status {
        case .authorised:
            let possiblyLinkedCard = paymentCards?.first(where: { !$0.linkedMembershipCards.isEmpty })
            guard membershipCard.linkedPaymentCards.isEmpty, !membershipCard.linkedPaymentCards.contains(possiblyLinkedCard as Any) else {
                // Link module 2.1
                return .pll(linkedPaymentCards: membershipCard.formattedLinkedPaymentCards, paymentCards: paymentCards)
            }
            if paymentCards?.isEmpty == true {
                // Link module 2.2
                return .pllNoPaymentCards
            } else {
                // Link module 2.3
                return .pllError
            }
        case .unauthorised:
            // Link module 2.5
            return .loginChanges(type: .link(membershipCard: membershipCard, paymentCards: paymentCards), status: .unauthorised, reasonCode: nil)
        case .pending:
            // Link module 2.6
            return .pending
        case .failed:
            if let reasonCode = membershipCard.status?.formattedReasonCodes?.first {
                switch reasonCode {
                case .enrolmentDataRejectedByMerchant:
                    return .signUp
                case .accountNotRegistered:
                    return .patchGhostCard(type: .link(membershipCard: membershipCard, paymentCards: paymentCards))
                default:
                    return .loginChanges(type: .link(membershipCard: membershipCard, paymentCards: paymentCards), status: .failed, reasonCode: nil)
                }
            } else {
                // Link module 2.7
                return .noReasonCode
            }
        default:
            fatalError("Unknown state")
        }
    }
}
