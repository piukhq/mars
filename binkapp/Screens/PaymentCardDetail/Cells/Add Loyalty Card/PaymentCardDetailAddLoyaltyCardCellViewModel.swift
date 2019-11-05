//
//  PaymentCardDetailAddLoyaltyCardCellViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 05/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PaymentCardDetailAddLoyaltyCardCellViewModel: PaymentCardDetailCellViewModelProtocol {

    private let membershipPlan: CD_MembershipPlan

    init(membershipPlan: CD_MembershipPlan) {
        self.membershipPlan = membershipPlan
    }

    var headerText: String? {
        return membershipPlan.account?.companyName
    }

    var detailText: String? {
        return "You can link this card"
    }

    var iconUrl: URL? {
        let iconImage = membershipPlan.firstIconImage()
        return URL(string: iconImage?.url ?? "")
    }
}
