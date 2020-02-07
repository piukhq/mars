//
//  PaymentCardDetailLoyaltyCardStatusCellViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 05/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PaymentCardDetailLoyaltyCardStatusCellViewModel: PaymentCardDetailCellViewModelProtocol {

    let membershipCard: CD_MembershipCard

    init(membershipCard: CD_MembershipCard) {
        self.membershipCard = membershipCard
    }

    var headerText: String? {
        return membershipCard.membershipPlan?.account?.companyName
    }

    var detailText: String? {
        switch status?.status {
        case .unauthorised, .failed, .pending:
            return nil
        default: return "pdc_you_can_link".localized
        }
    }

    var status: CD_MembershipCardStatus? {
        return membershipCard.status
    }

    var statusText: String? {
        switch status?.status {
        case .unauthorised, .failed:
            return "retry_title".localized
        default:
            return status?.status?.rawValue.capitalized
        }
    }
}
