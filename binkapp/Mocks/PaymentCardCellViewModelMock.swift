//
//  PaymentCardCellViewModelMock.swift
//  binkapp
//
//  Created by Nick Farrant on 17/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PaymentCardCellViewModelMock {
    private let paymentCard: PaymentCardModel

    init(paymentCard: PaymentCardModel) {
        self.paymentCard = paymentCard
    }

    var nameOnCardText: String? {
        return paymentCard.card?.nameOnCard
    }

    var cardNumberText: String? {
        return "••••   ••••   ••••   \(paymentCard.card?.lastFour ?? "")"
    }

    var paymentCardType: PaymentCardType? {
        return PaymentCardType.type(from: paymentCard.card?.firstSix)
    }

    var linkedText: String {
        if paymentCardIsLinkedToMembershipCards {
            return "Linked to \(linkedMembershipCardsCount) loyalty card\(linkedMembershipCardsCount > 1 ? "s" : "")"
        } else {
            return "Not linked"
        }
    }

    var paymentCardIsExpired: Bool {
        guard let card = paymentCard.card,
            let expiryYear = card.year,
            let expiryMonth = card.month else {
                return false
        }
        // Tech debt (casting to int)
        let date = Date.makeDate(year: Int(expiryYear), month: Int(expiryMonth), day: 01, hr: 12, min: 00, sec: 00)
        guard let expiryDate = date else {
            return false
        }
        return expiryDate < Date()
    }

    private var linkedMembershipCardsCount: Int {
        guard let cards = paymentCard.membershipCards else {
            return 0
        }
        return cards.filter({ $0.activeLink == true }).count
    }

    var paymentCardIsLinkedToMembershipCards: Bool {
        return linkedMembershipCardsCount > 0
    }
}
