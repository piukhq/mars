//
//  PaymentCardCell.swift
//  binkapp
//
//  Created by Dorin Pop on 01/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentCardCell: UITableViewCell {
    @IBOutlet private weak var paymentCardImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var switchButton: UISwitch!
    
    
    func configureUI(image: UIImage, title: String, subtitle: String) {
        paymentCardImageView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
        switchButton.setGradientBackground(firstColor: .binkPurple, secondColor: .blueAccent, orientation: .horizontal, roundedCorner: true)
    }
}
