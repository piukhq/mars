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

    var shouldShowLoginButton: Bool {
        return cardStatus == .failed
    }

    var shouldShowPointsValueLabels: Bool {
        return !shouldShowLoginButton || cardStatus == .pending || planHasPoints && balanceValue != nil
    }

    var shouldShowLinkStatus: Bool {
        return cardStatus == .authorised && planCardType == .link || cardStatus == .unauthorised && planCardType == .link
    }

    var brandColorHex: String? {
        return membershipCard.card?.colour
    }

    var companyName: String? {
        return membershipPlan?.account?.companyName
    }

    var linkStatusText: String? {
        switch cardStatus {
        case .authorised:
            return "card_linked_status".localized
        case .unauthorised:
            return "card_can_not_link_status".localized
        default:
            return nil
        }
    }

    var linkStatusImageName: String {
        switch cardStatus {
        case .authorised:
            return "linked"
        case .unauthorised:
            return "unlinked"
        default:
            return ""
        }
    }

    var pointsValueText: String {
        return "\(balance?.prefix ?? "")\(balance?.value?.stringValue ?? "")"
    }

    var pointsValueSuffixText: String? {
        return balance?.suffix
    }
}
