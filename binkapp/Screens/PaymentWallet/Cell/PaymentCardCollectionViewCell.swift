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
    private var viewModel: PaymentCardCellViewModel!

    func configureWithViewModel(_ viewModel: PaymentCardCellViewModel) {
        self.viewModel = viewModel

        nameOnCardLabel.text = viewModel.nameOnCardText
        cardNumberLabel.attributedText = viewModel.cardNumberText

        configureForProvider()
        configurePaymentCardLinkingStatus()

        setLabelStyling()
        setupShadow()
    }
    
    private func setLabelStyling() {
        nameOnCardLabel.font = .subtitle
        pllStatusLabel.font = .statusLabel

        [nameOnCardLabel, cardNumberLabel, pllStatusLabel].forEach {
            $0?.textColor = .white
        }
    }

    private func configureForProvider() {
        guard let cardType = viewModel.paymentCardType else {
            processGradient()
            return
        }

        providerLogoImageView.image = UIImage(named: cardType.logoName)
        providerWatermarkImageView.image = UIImage(named: cardType.sublogoName)

        processGradient()
    }

    private func configurePaymentCardLinkingStatus() {
        guard !viewModel.paymentCardIsExpired() else {
            alertView.configureForType(.paymentExpired) { [weak self] in
                self?.viewModel.expiredAction()
            }
            alertView.isHidden = false
            pllStatusLabel.isHidden = true
            linkedStatusImageView.isHidden = true
            return
        }

        pllStatusLabel.text = viewModel.linkedText
        linkedStatusImageView.image = imageForLinkedStatus()
    }

    private func imageForLinkedStatus() -> UIImage? {
        return viewModel.paymentCardIsLinkedToMembershipCards() ? UIImage(named: "linked") : UIImage(named: "unlinked")
    }

    private func processGradient() {
        if gradientLayer == nil {
            let gradient = CAGradientLayer()
            layer.insertSublayer(gradient, at: 0)
            gradientLayer = gradient
        }

        switch viewModel.paymentCardType {
        case .visa:
            gradientLayer?.colors = UIColor.visaPaymentCardGradients
        case .mastercard:
            gradientLayer?.colors = UIColor.mastercardPaymentCardGradients
        case .amex:
            gradientLayer?.colors = UIColor.amexPaymentCardGradients
        case .none:
            gradientLayer?.colors = UIColor.unknownPaymentCardGradients
        }

        gradientLayer?.frame = bounds
        gradientLayer?.locations = [0.0, 1.0]
        gradientLayer?.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer?.endPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer?.cornerRadius = LayoutHelper.WalletDimensions.cardCornerRadius
    }

    private func setupShadow() {
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.3
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        clipsToBounds = false
    }

}
