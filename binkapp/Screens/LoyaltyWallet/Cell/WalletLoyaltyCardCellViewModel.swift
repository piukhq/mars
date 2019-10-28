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
        return shouldShowRetryStatus || cardStatus == .pending || planHasPoints && balanceValue != nil
    }

    var shouldShowLinkStatus: Bool {
        return planCardType == .link
    }

    var brandColorHex: String? {
        return membershipCard.card?.colour
    }

    var companyName: String? {
        return membershipPlan?.account?.companyName
    }

    var hasLinkedPaymentCards: Bool {
        return membershipCard.linkedPaymentCards.count > 0
    }

    var linkStatusText: String? {
        switch (planCardType, hasLinkedPaymentCards) {
        case (.link, true):
            return "Linked".localized
        case (.link, false):
            return "Link now".localized
        default:
            return nil
        }

        // Linking error?
    }

    var linkStatusImageName: String {
        switch (planCardType, hasLinkedPaymentCards) {
        case (.link, true):
            return "linked"
        default:
            return "unlinked"
        }

        // Linking error?
    }

    var pointsValueText: String {
        guard cardStatus != .pending else {
            return "pending_title".localized
        }
        guard !shouldShowRetryStatus else {
            return "retry_title".localized
        }
        return "\(balance?.prefix ?? "")\(balance?.value?.stringValue ?? "")"
    }

    var pointsValueSuffixText: String? {
        return balance?.suffix
    }
}
