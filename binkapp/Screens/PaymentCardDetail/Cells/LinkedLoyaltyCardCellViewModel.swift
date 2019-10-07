//
//  LinkedLoyaltyCardCellViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 07/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct LinkedLoyaltyCellViewModel {
    let membershipCard: CD_MembershipCard
    let isLinked: Bool

    init(membershipCard: CD_MembershipCard, isLinked: Bool) {
        self.membershipCard = membershipCard
        self.isLinked = isLinked
    }

    var companyNameText: String? {
        return membershipCard.membershipPlan?.account?.companyName
    }

    var iconUrl: URL? {
        let iconImage = membershipCard.membershipPlan?.firstIconImage()
        return URL(string: iconImage?.url ?? "")
    }
}
