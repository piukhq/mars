//
//  PLRRewardsHistoryViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 13/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PLRRewardsHistoryViewModel {
    private let membershipCard: CD_MembershipCard
    private let router: MainScreenRouter

    init(membershipCard: CD_MembershipCard, router: MainScreenRouter) {
        self.membershipCard = membershipCard
        self.router = router
    }

    var navigationTitle: String? {
        return membershipCard.membershipPlan?.account?.companyName
    }

    var titleText: String {
        return "Rewards history"
    }

    var subtitleText: String {
        return "Your past rewards"
    }

    var vouchers: [CD_Voucher]? {
        return membershipCard.inactiveVouchers
    }

    var vouchersCount: Int {
        return vouchers?.count ?? 0
    }

    func voucherForIndexPath(_ indexPath: IndexPath) -> CD_Voucher? {
        return vouchers?[indexPath.row]
    }

    func toVoucherDetailScreen(voucher: CD_Voucher) {
        guard let plan = membershipCard.membershipPlan else {
            fatalError("Membership card has no membership plan attributed to it. This should never be the case.")
        }
        router.toVoucherDetailViewController(voucher: voucher, plan: plan)
    }
}
