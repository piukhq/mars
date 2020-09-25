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

    init(paymentCard: CD_PaymentCard) {
        self.paymentCard = paymentCard
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
    
    var paymentCardIsActive: Bool {
        return paymentCardStatus == .active
    }

    var statusText: String? {
        guard let status = paymentCardStatus else {
            return nil
        }
        
        switch status {
        case .pending, .failed:
            return status.rawValue.capitalized
        case .active:
            if paymentCardIsLinkedToMembershipCards {
                return "Linked to \(linkedMembershipCardsCount) loyalty card\(linkedMembershipCardsCount > 1 ? "s" : "")"
            } else {
                return "Not linked"
            }
        }
    }

    func expiredAction() {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: "payment_card_expired_alert_title".localized, message: "payment_card_expired_alert_message".localized)
        Current.navigate.to(AlertNavigationRequest(alertController: alert))
    }

    var paymentCardIsExpired: Bool {
        return paymentCard.isExpired()
    }
    
    private var paymentCardStatus: PaymentCardStatus? {
        return paymentCard.paymentCardStatus
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
