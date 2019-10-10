//
//  PaymentCardCell.swift
//  binkapp
//
//  Created by Dorin Pop on 01/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import AlamofireImage

class PaymentCardCell: UITableViewCell {
    @IBOutlet private weak var paymentCardImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var switchButton: BinkSwitch!
        
    func configureUI(paymentCard: CD_PaymentCard) {
        if let imageUrlString = paymentCard.imagesArray.first?.url {
            guard let imageUrl = URL(string: imageUrlString) else { return }
            paymentCardImageView.af_setImage(withURL: imageUrl)
        }
        titleLabel.text = paymentCard.card?.nameOnCard
        subtitleLabel.text = "pll_screen_card_ending".localized + (paymentCard.card?.lastFour ?? "")
    }
    
    // MARK: - Actions
    
    @IBAction func switchDidChangeValue(_ sender: BinkSwitch) {
        switchButton.isGradientVisible = sender.isOn
    }
}
