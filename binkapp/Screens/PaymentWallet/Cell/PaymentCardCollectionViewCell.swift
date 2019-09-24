//
//  PaymentCardCollectionViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 24/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameOnCardLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var pllStatusLabel: UILabel!
    @IBOutlet weak var providerLogoImageView: UIImageView!
    @IBOutlet weak var providerWatermarkImageView: UIImageView!

    func configureWithPaymentCard(_ paymentCard: PaymentCardModel) {
        layer.cornerRadius = 8

        nameOnCardLabel.text = paymentCard.card?.nameOnCard
        cardNumberLabel.attributedText = cardNumberAttributedString(paymentCard)
        pllStatusLabel.text = paymentCardLinkingText(paymentCard)

        configureForProvider(paymentCard.card?.provider)
        setLabelStyling()
    }

    private func setLabelStyling() {
        nameOnCardLabel.font = .subtitle
//        cardNumberLabel.font = .buttonText
        pllStatusLabel.font = .statusLabel

        [nameOnCardLabel, cardNumberLabel, pllStatusLabel].forEach {
            $0?.textColor = .white
        }
    }

    private func configureForProvider(_ provider: PaymentCardProvider?) {
        guard let provider = provider else {
            return
        }
        switch provider {
        case .visa:
            containerView.backgroundColor = .blue
        case .mastercard:
            containerView.backgroundColor = .orange
        case .amex:
            containerView.backgroundColor = .green
        }
    }

    private func paymentCardLinkingText(_ paymentCard: PaymentCardModel) -> String {
        if paymentCardIsLinkedToMembershipCards(paymentCard) {
            return "Linked to \(linkedMembershipCardsCount(paymentCard)) loyalty cards" // TODO: Account for 1 card in string
        } else {
            return "Not linked"
        }

        // TODO: expiry strings and views
    }

    private func linkedMembershipCardsCount(_ paymentCard: PaymentCardModel) -> Int {
        guard let membershipCards = paymentCard.membershipCards else {
            return 0
        }
        return membershipCards.filter { $0.activeLink == true }.count
    }

    private func paymentCardIsLinkedToMembershipCards(_ paymentCard: PaymentCardModel) -> Bool {
        return linkedMembershipCardsCount(paymentCard) != 0
    }

    private func cardNumberAttributedString(_ paymentCard: PaymentCardModel) -> NSAttributedString? {
        guard let redactedPrefix = paymentCard.card?.provider?.redactedPrefix else {
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

}
