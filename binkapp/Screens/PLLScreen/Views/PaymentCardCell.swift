//
//  PaymentCardCell.swift
//  binkapp
//
//  Created by Dorin Pop on 01/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import AlamofireImage

protocol PaymentCardCellDelegate: class {
    func paymentCardCellDidToggleSwitch(_ paymentCell: PaymentCardCell, cardIndex: Int)
}

class PaymentCardCell: UITableViewCell {
    @IBOutlet private weak var paymentCardImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var switchButton: BinkSwitch!
    private weak var delegate: PaymentCardCellDelegate?
    private let activityIndicator = UIActivityIndicatorView()
    private var cardIndex = 0
    private var firstUse = true
    
    func configureUI(membershipCard: CD_MembershipCard, paymentCard: CD_PaymentCard, cardIndex: Int, delegate: PaymentCardCellDelegate, journey: PLLScreenViewController.PllScreenJourney) {
        self.delegate = delegate
        self.cardIndex = cardIndex

        switch paymentCard.card?.providerName {
        case .visa:
            paymentCardImageView.image = UIImage(named: "visalogoContainer")
            break
        case .americanexpress:
            paymentCardImageView.image = UIImage(named: "americanexpresslogoContainer")
            break
        case .mastercard:
            paymentCardImageView.image = UIImage(named: "mastercardlogoContainer")
            break
        default:
            break
        }
        titleLabel.text = paymentCard.card?.nameOnCard
        subtitleLabel.text = "pll_screen_card_ending".localized + (paymentCard.card?.lastFour ?? "")
        if firstUse {
            switchButton.isOn = journey == .newCard ? true : membershipCard.linkedPaymentCards.contains(paymentCard)
            firstUse = false
        }
    }
    
    // MARK: - Actions
    
    @IBAction func switchDidChangeValue(_ sender: BinkSwitch) {
        switchButton.isGradientVisible = sender.isOn
        delegate?.paymentCardCellDidToggleSwitch(self, cardIndex: cardIndex)
    }
}
