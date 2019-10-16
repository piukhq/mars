//
//  JoinCard.swift
//  binkapp
//
//  Created by Nick Farrant on 16/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct JoinCard {
    static func userDefaultsKey(forPlan plan: CD_MembershipPlan) -> String {
        // TODO: What if the plan returns no plan name?
        return "join_card_\(plan.account?.planName ?? "")_was_dismissed"
    }

    let membershipPlan: CD_MembershipPlan

    init(membershipPlan: CD_MembershipPlan) {
        self.membershipPlan = membershipPlan
    }

    var title: String? {
        return membershipPlan.account?.planName
    }

    var body: String? {
        return "Link this card to your payment cards to automatically collect rewards."
    }

    var iconImageUrl: URL? {
        guard let urlString = membershipPlan.firstIconImage()?.url else {
            return nil
        }
        return URL(string: urlString) ?? nil
    }

    var userDefaultsKey: String {
        return JoinCard.userDefaultsKey(forPlan: membershipPlan)
    }
}
