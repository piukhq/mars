//
//  BarcodeViewCompact.swift
//  binkapp
//
//  Created by Sean Williams on 13/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class BarcodeViewCompact: BarcodeView {
    func configure(viewModel: LoyaltyCardFullDetailsViewModel) {
        cardNumberLabel.text = viewModel.barcodeViewModel.cardNumber
        
        if let plan = viewModel.membershipCard.membershipPlan {
            iconImageView.setImage(forPathType: .membershipPlanIcon(plan: plan), animated: true)
        }
        
        if let barcodeImage = viewModel.barcodeViewModel.barcodeImage(withSize: barcodeImageView.frame.size) {
            barcodeImageView.image = barcodeImage
        }
        
        /// Custom card
        let primaryBrandColor = UIColor(hexString: viewModel.membershipCard.card?.colour ?? "")
        iconImageView.backgroundColor = primaryBrandColor
        customCardIconLabel.text = viewModel.brandName.first?.uppercased()
        customCardIconLabel.font = .customCardLogo
    }
}
