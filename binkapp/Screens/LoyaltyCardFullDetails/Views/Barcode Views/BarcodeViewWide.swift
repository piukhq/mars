//
//  BarcodeViewWide.swift
//  binkapp
//
//  Created by Sean Williams on 12/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class BarcodeViewWide: BarcodeView {
    func configure(viewModel: LoyaltyCardFullDetailsViewModel) {
        cardNumberLabel.text = viewModel.barcodeViewModel.cardNumber
        
        if let plan = viewModel.membershipCard.membershipPlan {
            iconImageView.setImage(forPathType: .membershipPlanIcon(plan: plan), animated: true)
        }
        
        if let barcodeImage = viewModel.barcodeViewModel.barcodeImage(withSize: barcodeImageView.frame.size) {
            barcodeImageView.image = barcodeImage
        }
        
        if viewModel.barcodeViewModel.barcodeType == .pdf417 {
            barcodeImageView.contentMode = .scaleAspectFit
        }
        
        /// Custom card
        if viewModel.cardIsCustomCard {
            let primaryBrandColor = UIColor(hexString: viewModel.membershipCard.card?.colour ?? "")
            let textColor: UIColor = primaryBrandColor.isLight(threshold: 0.8) ? .black : .white

            iconImageView.backgroundColor = primaryBrandColor
            customCardIconLabel.text = viewModel.brandName.first?.uppercased()
            customCardIconLabel.font = .customCardLogoSmall
            customCardIconLabel.textColor = textColor
        }
    }
}
