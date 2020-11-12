//
//  PaymentCardCell.swift
//  binkapp
//
//  Created by Dorin Pop on 01/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol PaymentCardCellDelegate: class {
    func paymentCardCellDidToggleSwitch(_ paymentCell: PaymentCardCell, cardIndex: Int)
}

class PaymentCardCell: UITableViewCell {
    @IBOutlet private weak var paymentCardImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var switchButton: BinkSwitch!
    private weak var delegate: PaymentCardCellDelegate?
    private var cardIndex = 0
    private var firstUse = true
    
    func configureUI(paymentCard: CD_PaymentCard, cardIndex: Int, delegate: PaymentCardCellDelegate, journey: PllScreenJourney, showAsLinked: Bool) {
        self.delegate = delegate
        self.cardIndex = cardIndex

        switch PaymentCardType.type(from: paymentCard.card?.firstSix) {
        case .visa:
            paymentCardImageView.image = UIImage(named: "visalogoContainer")
        case .amex:
            paymentCardImageView.image = UIImage(named: "americanexpresslogoContainer")
        case .mastercard:
            paymentCardImageView.image = UIImage(named: "mastercardlogoContainer")
        default:
            break
        }
        titleLabel.text = paymentCard.card?.nameOnCard
        subtitleLabel.text = String(format: "pll_screen_card_ending".localized, paymentCard.card?.lastFour ?? "")
        switchButton.isOn = journey == .newCard ? true : showAsLinked
        
        selectionStyle = .none
    }
    
    // MARK: - Actions
    
    @IBAction func switchDidChangeValue(_ sender: BinkSwitch) {
        switchButton.isGradientVisible = sender.isOn
        delegate?.paymentCardCellDidToggleSwitch(self, cardIndex: cardIndex)
    }
}
