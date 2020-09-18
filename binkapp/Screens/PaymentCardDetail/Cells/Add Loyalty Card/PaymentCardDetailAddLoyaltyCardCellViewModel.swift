//
//  PaymentCardDetailAddLoyaltyCardCellViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 05/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PaymentCardDetailAddLoyaltyCardCellViewModel: PaymentCardDetailCellViewModelProtocol {
    let membershipPlan: CD_MembershipPlan

    init(membershipPlan: CD_MembershipPlan) {
        self.membershipPlan = membershipPlan
    }

    var headerText: String? {
        return membershipPlan.account?.companyName
    }

    var detailText: String? {
        return "pcd_you_can_link".localized
    }

    func toAddOrJoin() {
//        router.toAddOrJoinViewController(membershipPlan: membershipPlan)
    }
}
