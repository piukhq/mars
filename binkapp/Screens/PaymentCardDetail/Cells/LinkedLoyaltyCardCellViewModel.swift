//
//  LinkedLoyaltyCardCellViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 07/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct LinkedLoyaltyCellViewModel {
    private(set) var membershipCard: CD_MembershipCard
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

    var pointsValueText: String? {
        let balance = membershipCard.balances.allObjects.first as? CD_MembershipCardBalance
        guard let balanceValue = balance?.value else {
            return nil // If there is no value, don't show the points label
        }
        
        guard balance?.prefix != nil else {
            return "\(balanceValue) \(balance?.suffix ?? "")"
        }
        
        let floatBalanceValue = Float(truncating: balanceValue)
        
        if (floatBalanceValue - floatBalanceValue.rounded(.down) > 0) {
            return "\(balance?.prefix ?? "")" + String(format: "%.02f", balanceValue)
        } else {
            return "\(balance?.prefix ?? "") \(balanceValue)"
        }
        
//        return "\(balance?.prefix ?? "")\(balanceValue) \(balance?.suffix ?? "")"
    }
}
