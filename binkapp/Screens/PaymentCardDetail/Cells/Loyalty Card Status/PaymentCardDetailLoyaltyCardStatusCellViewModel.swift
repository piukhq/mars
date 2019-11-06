//
//  PaymentCardDetailLoyaltyCardStatusCellViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 05/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PaymentCardDetailLoyaltyCardStatusCellViewModel: PaymentCardDetailCellViewModelProtocol {

    private let membershipCard: CD_MembershipCard

    init(membershipCard: CD_MembershipCard) {
        self.membershipCard = membershipCard
    }

    var headerText: String? {
        return membershipCard.membershipPlan?.account?.companyName
    }

    var detailText: String? {
        return "You can link this card"
    }

    var iconUrl: URL? {
        let iconImage = membershipCard.membershipPlan?.firstIconImage()
        return URL(string: iconImage?.url ?? "")
    }

    var status: CD_MembershipCardStatus? {
        return membershipCard.status
    }

    var statusText: String? {
        switch status?.status {
        case .unauthorised, .failed:
            return "Retry"
        default:
            return status?.status?.rawValue.uppercased()
        }
    }
}
