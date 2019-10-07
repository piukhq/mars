//
//  PaymentCardDetailViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 03/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PaymentCardDetailViewModel {
    private var paymentCard: CD_PaymentCard
    private let router: MainScreenRouter

    init(paymentCard: CD_PaymentCard, router: MainScreenRouter) {
        self.paymentCard = paymentCard
        self.router = router
    }

    var paymentCardCellViewModel: PaymentCardCellViewModel {
        return PaymentCardCellViewModel(paymentCard: paymentCard, router: router)
    }

    var paymentCardId: String {
        return paymentCard.id
    }

    var linkedMembershipCardIds: [String]? {
        let membershipCards = paymentCard.linkedMembershipCards as? Set<CD_MembershipCard>
        return membershipCards?.map { $0.id }
    }

    func membershipCardIsLinked(_ membershipCard: CD_MembershipCard) -> Bool {
        return linkedMembershipCardIds?.contains(membershipCard.id) ?? false
    }

    mutating func setNewPaymentCard(_ paymentCard: CD_PaymentCard) {
        self.paymentCard = paymentCard
    }
}
