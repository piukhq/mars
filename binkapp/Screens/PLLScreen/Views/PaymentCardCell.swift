//
//  PaymentCardCell.swift
//  binkapp
//
//  Created by Dorin Pop on 01/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol PaymentCardCellDelegate: AnyObject {
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
        
        paymentCardImageView.setImage(forPaymentCardFirstSix: paymentCard.card?.firstSix ?? "")
        titleLabel.text = paymentCard.card?.nameOnCard
        titleLabel.textColor = Current.themeManager.color(for: .text)
        subtitleLabel.text = L10n.pllScreenCardEnding(paymentCard.card?.lastFour ?? "")
        subtitleLabel.textColor = Current.themeManager.color(for: .text)
        switchButton.isOn = journey == .newCard ? true : showAsLinked
        
        selectionStyle = .none
    }
    
    // MARK: - Actions
    
    @IBAction func switchDidChangeValue(_ sender: BinkSwitch) {
        switchButton.isGradientVisible = sender.isOn
        delegate?.paymentCardCellDidToggleSwitch(self, cardIndex: cardIndex)
    }
}
