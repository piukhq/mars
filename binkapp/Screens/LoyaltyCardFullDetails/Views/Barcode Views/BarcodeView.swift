//
//  BarcodeView.swift
//  binkapp
//
//  Created by Sean Williams on 12/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class BarcodeView: UIView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var barcodeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 12
        clipsToBounds = true
        backgroundColor = Current.themeManager.color(for: .walletCardBackground)
        titleLabel.textColor = Current.themeManager.color(for: .text)
        cardNumberLabel.textColor = Current.themeManager.color(for: .text)
    }
}
