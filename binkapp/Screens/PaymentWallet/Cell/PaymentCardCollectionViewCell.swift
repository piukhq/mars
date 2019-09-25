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

    private var gradientLayer: CAGradientLayer?
 
    func configureWithPaymentCard(_ paymentCard: PaymentCardModel) {
        layer.cornerRadius = LayoutHelper.WalletDimensions.cardCornerRadius

        nameOnCardLabel.text = paymentCard.card?.nameOnCard
        cardNumberLabel.attributedText = cardNumberAttributedString(paymentCard)

        configureForProvider(paymentCard)
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

    private func configureForProvider(_ paymentCard: PaymentCardModel?) {
        guard let provider = PaymentCardType.type(from: paymentCard?.card?.firstSix) else {
            return
        }
        switch provider {
        case .visa:
            processGradient(UIColor(hexString: "181c51"), UIColor(hexString: "13288d"))
        case .mastercard:
            processGradient(UIColor(hexString: "eb001b"), UIColor(hexString: "f79e1b"))
        case .amex:
            processGradient(UIColor(hexString: "006bcd"), UIColor(hexString: "57c4ff"))
        }

        providerLogoImageView.image = UIImage(named: provider.logoName)
        providerWatermarkImageView.image = UIImage(named: provider.sublogoName)
    }

    private func configurePaymentCardLinkingStatus(_ paymentCard: PaymentCardModel) {
        guard !paymentCardIsExpired(paymentCard) else {
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

    private func processGradient(_ firstColor: UIColor, _ secondColor: UIColor) {
        if gradientLayer == nil {
            let gradient = CAGradientLayer()
            layer.insertSublayer(gradient, at: 0)
            gradientLayer = gradient
        }

        gradientLayer?.frame = bounds
        gradientLayer?.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer?.locations = [0.0, 1.0]
        gradientLayer?.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer?.endPoint = CGPoint(x: 0.0, y: 0.0)
    }

}
