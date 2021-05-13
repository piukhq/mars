//
//  WalletLoyaltyCardCellViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 01/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct WalletLoyaltyCardCellViewModel {
    private let membershipCard: CD_MembershipCard

    init(membershipCard: CD_MembershipCard) {
        self.membershipCard = membershipCard
    }

    var membershipPlan: CD_MembershipPlan? {
        return membershipCard.membershipPlan
    }

    // Tech debt
    var cardStatus: MembershipCardStatus? {
        return membershipCard.status?.status
    }

    var balance: CD_MembershipCardBalance? {
        return membershipCard.balances.allObjects.first as? CD_MembershipCardBalance
    }

    var balanceValue: Int? {
        return balance?.value?.intValue
    }

    var planHasPoints: Bool {
        return membershipPlan?.featureSet?.hasPoints?.boolValue ?? false
    }

    var planCardType: CD_FeatureSet.PlanCardType? {
        return membershipPlan?.featureSet?.planCardType
    }

    var shouldShowRetryStatus: Bool {
        return (cardStatus == .failed || cardStatus == .unauthorised) && membershipPlan?.featureSet?.planCardType != .store
    }

    var shouldShowPointsValueLabel: Bool {
        guard membershipPlan?.featureSet?.planCardType != .store  else {
            return false
        }
        return shouldShowRetryStatus || cardStatus == .pending || planHasPoints && balanceValue != nil || cardStatus == .authorised && membershipCard.balances.allObjects.isEmpty
    }

    var shouldShowPointsSuffixLabel: Bool {
        return cardStatus == .authorised
    }

    var shouldShowLinkStatus: Bool {
        return planCardType == .link
    }

    var shouldShowLinkImage: Bool {
        return !linkStatusImageName.isEmpty
    }

    var brandColorHex: String? {
        return membershipCard.card?.colour
    }

    var companyName: String? {
        return membershipPlan?.account?.companyName
    }

    var hasLinkedPaymentCards: Bool {
        return membershipCard.status?.status == .authorised && !membershipCard.linkedPaymentCards.isEmpty
    }

    var linkStatusText: String? {
        guard !shouldShowRetryStatus else { return L10n.retryTitle }
        guard cardStatus != .pending else { return L10n.pendingTitle }
        switch (planCardType, hasLinkedPaymentCards) {
        case (.link, true):
            return L10n.cardLinkedStatus
        case (.link, false):
            return L10n.cardLinkNowStatus
        default:
            return nil
        }

        // Linking error?
    }

    var linkStatusImageName: String {
        guard !shouldShowRetryStatus else { return "" }
        guard cardStatus != .pending else { return "" }
        switch (planCardType, hasLinkedPaymentCards) {
        case (.link, true):
            return L10n.linkedStatusImageName
        case (.link, false):
            return L10n.unlinkedStatusImageName
        default:
            return ""
        }

        // Linking error?
    }

    var pointsValueText: String? {
        guard cardStatus != .pending else {
            return L10n.pendingTitle
        }
        guard !shouldShowRetryStatus else {
            return L10n.retryTitle
        }

        // PLR
        if membershipPlan?.isPLR == true && cardStatus == .authorised {
            guard let voucher = membershipCard.activeVouchers?.first(where: {
                let state = VoucherState(rawValue: $0.state ?? "")
                return state == .inProgress
            }) else { return nil }
            return voucher.balanceString
        }
        
        if cardStatus == .authorised && membershipCard.balances.isEmpty {
            return L10n.pendingTitle
        }

        let floatBalanceValue = balance?.value?.floatValue ?? 0
        
        guard let prefix = balance?.prefix else {
            return balance?.value?.stringValue ?? ""
        }

        if floatBalanceValue.hasDecimals {
            return "\(prefix)" + String(format: "%.02f", floatBalanceValue)
        } else {
            return "\(prefix)\(Int(floatBalanceValue))"
        }
    }

    var pointsValueSuffixText: String? {
        // PLR
        if membershipPlan?.isPLR == true && cardStatus == .authorised {
            if let earnType = membershipCard.vouchersEarnType {
                switch earnType {
                case .accumulator:
                    return L10n.plrLoyaltyCardSubtitleAccumulator
                case .stamps:
                    return L10n.plrLoyaltyCardSubtitleStamps
                }
            }
        }
        return balance?.suffix
    }
}

extension NSSet {
    var isEmpty: Bool {
        return allObjects.isEmpty
    }
}
