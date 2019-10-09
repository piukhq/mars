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
    
    private var backgroundGradientLayer = CAGradientLayer()
    
    override func layoutSubviews() {
        backgroundGradientLayer.frame = switchButton.bounds
        backgroundGradientLayer.colors = UIColor.binkSwitchGradients
        backgroundGradientLayer.locations = [0.0, 1.0]
        backgroundGradientLayer.cornerRadius = switchButton.frame.size.height / 2
        backgroundGradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
    }
    
    func configureUI(paymentCard: CD_PaymentCard) {
//        paymentCardImageView.image = paymentCard.
//        titleLabel.text = title
//        subtitleLabel.text = subtitle
//        let binkGradientColor = colorWithGradient(frame: switchButton.frame, colors: [.binkPurple, .blueAccent])
//        switchButton.onTintColor = binkGradientColor
//        switchButton.tintColor = .gray//
    }
    @IBAction func switchDidChangeValue(_ sender: UISwitch) {
        if sender.isOn {
            switchButton.layer.insertSublayer(backgroundGradientLayer, at: 0)
        } else {
            backgroundGradientLayer.removeFromSuperlayer()
        }
    }
}
