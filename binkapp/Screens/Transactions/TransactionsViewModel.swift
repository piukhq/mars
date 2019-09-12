//
//  TransactionsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class TransactionsViewModel {
    private let router: MainScreenRouter
    let membershipCard: MembershipCardModel
    
    init(membershipCard: MembershipCardModel, router: MainScreenRouter) {
        self.membershipCard = membershipCard
        self.router = router
    }
    
    func getLastCheckedString() -> String {
        let date = Date(timeIntervalSince1970: membershipCard.balances?.first?.updatedAt ?? 0)
        let dateString = date.timeAgoSinceDate()
        return String(format: "last_checked".localized, dateString)
    }
    
    func popViewController() {
        router.popViewController()
    }
}
