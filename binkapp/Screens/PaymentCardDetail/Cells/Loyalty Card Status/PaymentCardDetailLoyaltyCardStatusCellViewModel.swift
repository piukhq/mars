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
        return "Testing"
    }

    var detailText: String? {
        return "123"
    }

    var iconUrl: URL? {
        let iconImage = membershipCard.membershipPlan?.firstIconImage()
        return URL(string: iconImage?.url ?? "")
    }
}
