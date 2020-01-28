//
//  PaymentCardCellViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 25/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

struct PaymentCardCellViewModel {
    private let paymentCard: CD_PaymentCard
    private let router: MainScreenRouter?

    init(paymentCard: CD_PaymentCard, router: MainScreenRouter? = nil) {
        self.paymentCard = paymentCard
        self.router = router
    }

    var nameOnCardText: String? {
        return paymentCard.card?.nameOnCard
    }

    var cardNumberText: NSAttributedString? {
        return cardNumberAttributedString()
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

    func expiredAction() {
        router?.displaySimplePopup(title: "Expired Payment Card", message: "This payment card has expired.")
    }

    var paymentCardIsExpired: Bool {
        return paymentCard.isExpired()
    }

    private func cardNumberAttributedString() -> NSAttributedString? {
        guard let redactedPrefix = paymentCardType?.redactedPrefix else {
            return nil
        }
        guard let lastFour = paymentCard.card?.lastFour else {
            return nil
        }

        // https://stackoverflow.com/questions/19487369/center-two-fonts-with-different-different-sizes-vertically-in-an-nsattributedstr?rq=1
        let offset = (UIFont.buttonText.capHeight - UIFont.redactedCardNumberPrefix.capHeight) / 2

        let attributedString = NSMutableAttributedString()
        attributedString.append(NSMutableAttributedString(string: redactedPrefix, attributes: [.font: UIFont.redactedCardNumberPrefix, .baselineOffset: offset, .kern: 1.5]))
        attributedString.append(NSMutableAttributedString(string: lastFour, attributes: [.font: UIFont.buttonText, .kern: 0.2]))

        return attributedString
    }

    private var linkedMembershipCardsCount: Int {
        guard let membershipCards = paymentCard.linkedMembershipCards as? Set<CD_MembershipCard> else {
            return 0
        }
        return membershipCards.count
    }

    var paymentCardIsLinkedToMembershipCards: Bool {
        return linkedMembershipCardsCount > 0
    }
}
