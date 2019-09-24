//
//  PaymentCardCollectionViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 24/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var nameOnCardLabel: UILabel!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var pllStatusLabel: UILabel!
    @IBOutlet private weak var linkedStatusImageView: UIImageView!
    @IBOutlet private weak var providerLogoImageView: UIImageView!
    @IBOutlet private weak var providerWatermarkImageView: UIImageView!
    @IBOutlet private weak var alertView: CardAlertView!

    func configureWithPaymentCard(_ paymentCard: PaymentCardModel) {
        layer.cornerRadius = 8

        nameOnCardLabel.text = paymentCard.card?.nameOnCard
        cardNumberLabel.attributedText = cardNumberAttributedString(paymentCard)

        configureForProvider(paymentCard.card?.provider)
        configurePaymentCardLinkingStatus(paymentCard)

        setLabelStyling()
    }

    private func setLabelStyling() {
        nameOnCardLabel.font = .subtitle
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

    private func configurePaymentCardLinkingStatus(_ paymentCard: PaymentCardModel) {
        guard paymentCardIsExpired(paymentCard) else {
            alertView.configureForType(.paymentExpired)
            alertView.isHidden = false
            pllStatusLabel.isHidden = true
            linkedStatusImageView.isHidden = true
            return
        }
        if paymentCardIsLinkedToMembershipCards(paymentCard) {
            pllStatusLabel.text = "Linked to \(linkedMembershipCardsCount(paymentCard)) loyalty cards" // TODO: Account for 1 card in string
        } else {
            pllStatusLabel.text = "Not linked"
        }

        linkedStatusImageView.image = imageForLinkedStatus(paymentCard)
    }

    private func imageForLinkedStatus(_ paymentCard: PaymentCardModel) -> UIImage? {
        return paymentCardIsLinkedToMembershipCards(paymentCard) ? UIImage(named: "linked") : UIImage(named: "unlinked")
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

    private func paymentCardIsExpired(_ paymentCard: PaymentCardModel) -> Bool {
        guard let card = paymentCard.card else {
            return false
        }
        guard let expiryYear = card.year else {
            return false
        }
        guard let expiryMonth = card.month else {
            return false
        }
        guard let expiryDate = Date.makeDate(year: expiryYear, month: expiryMonth, day: 01, hr: 00, min: 00, sec: 00) else {
            return false
        }
        return expiryDate < Date()
    }

}
