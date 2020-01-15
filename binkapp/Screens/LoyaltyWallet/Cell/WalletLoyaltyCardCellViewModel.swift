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
    var cardStatus: CD_MembershipCardStatus.MembershipCardStatus? {
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

    var shouldShowPointsValueLabels: Bool {
        guard membershipPlan?.featureSet?.planCardType != .store  else {
            return false
        }
        return shouldShowRetryStatus || cardStatus == .pending || planHasPoints && balanceValue != nil || cardStatus == .authorised && membershipCard.balances.allObjects.isEmpty
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
        return membershipCard.status?.status == .authorised && membershipCard.linkedPaymentCards.count > 0
    }

    var linkStatusText: String? {
        guard !shouldShowRetryStatus else { return "retry_title".localized }
        guard cardStatus != .pending else { return "pending_title".localized }
        switch (planCardType, hasLinkedPaymentCards) {
        case (.link, true):
            return "card_linked_status".localized
        case (.link, false):
            return "card_link_now_status".localized
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
            return "linked_status_image_name".localized
        case (.link, false):
            return "unlinked_status_image_name".localized
        default:
            return ""
        }

        // Linking error?
    }

    var pointsValueText: String? {
        guard cardStatus != .pending else {
            return "pending_title".localized
        }
        guard !shouldShowRetryStatus else {
            return "retry_title".localized
        }

        // PLR
        if membershipPlan?.isPLR == true && cardStatus == .authorised {
            guard let voucher = membershipCard.activeVouchers?.first else { return "" }
            return voucher.balanceString
        }
        
        if cardStatus == .authorised && membershipCard.balances.allObjects.isEmpty {
            return "pending_title".localized
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
            return "plr_loyalty_card_subtitle".localized
        }
        return balance?.suffix
    }
}
