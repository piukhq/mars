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
    private let router: MainScreenRouter

    init(membershipPlan: CD_MembershipPlan, router: MainScreenRouter) {
        self.membershipPlan = membershipPlan
        self.router = router
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

    func toAddOrJoin() {
        router.toAddOrJoinViewController(membershipPlan: membershipPlan)
    }
}
