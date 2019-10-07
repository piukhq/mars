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

    var titleText: String {
        return "Linked cards"
    }

    var descriptionText: String {
        return "The active loyalty cards below are linked to this payment card. Simply pay as usual to collect points."
    }

    var paymentCardCellViewModel: PaymentCardCellViewModel {
        return PaymentCardCellViewModel(paymentCard: paymentCard)
    }

    var paymentCardId: String {
        return paymentCard.id
    }

    var linkableMembershipCards: [CD_MembershipCard]? {
        return Current.wallet.membershipCards?.filter( { $0.membershipPlan?.featureSet?.planCardType == .link })
    }

    var pllEnabledMembershipCardsCount: Int {
        return linkableMembershipCards?.count ?? 0
    }

    var linkedMembershipCardIds: [String]? {
        let membershipCards = paymentCard.linkedMembershipCards as? Set<CD_MembershipCard>
        return membershipCards?.map { $0.id }
    }

    func membershipCardIsLinked(_ membershipCard: CD_MembershipCard) -> Bool {
        return linkedMembershipCardIds?.contains(membershipCard.id) ?? false
    }

    func membershipCard(forIndexPath indexPath: IndexPath) -> CD_MembershipCard? {
        return linkableMembershipCards?[indexPath.row]
    }

    mutating func setNewPaymentCard(_ paymentCard: CD_PaymentCard) {
        self.paymentCard = paymentCard
    }
}
