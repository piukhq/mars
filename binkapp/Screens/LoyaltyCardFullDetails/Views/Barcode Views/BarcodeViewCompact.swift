//
//  BarcodeViewCompact.swift
//  binkapp
//
//  Created by Sean Williams on 13/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

class BarcodeViewCompact: BarcodeView {
    func configure(viewModel: LoyaltyCardFullDetailsViewModel) {
        cardNumberLabel.text = viewModel.barcodeViewModel.cardNumber
        
        if let plan = viewModel.membershipCard.membershipPlan {
            iconImageView.setImage(forPathType: .membershipPlanIcon(plan: plan))
        }
        
        if let barcodeImage = viewModel.barcodeViewModel.barcodeImage(withSize: barcodeImageView.frame.size) {
            barcodeImageView.image = barcodeImage
        }
    }
}
