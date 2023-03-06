//
//  BarcodeView.swift
//  binkapp
//
//  Created by Sean Williams on 12/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class BarcodeView: UIView {
    @IBOutlet weak var barcodeImageContainerView: UIView!
    @IBOutlet weak var barcodeImageContainer: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var barcodeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var customCardIconLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 12
        clipsToBounds = true
        backgroundColor = Current.themeManager.color(for: .walletCardBackground)
        iconImageView.layer.cornerRadius = LayoutHelper.iconCornerRadius
        iconImageView.layer.cornerCurve = .continuous
        titleLabel.text = L10n.barcodeViewTitle
        titleLabel.textColor = Current.themeManager.color(for: .text)
        cardNumberLabel.textColor = Current.themeManager.color(for: .text)
        copyButton.tintColor = Current.themeManager.color(for: .text)
    }
    
    @IBAction func copyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = cardNumberLabel.text
        MessageView.show(L10n.snackbarMessageCopiedCardNumber, type: .snackbar(.short))
        MixpanelUtility.track(.cardNumberCopiedToPasteboard)
    }
}
