//
//  BarcodeViewNoBarcode.swift
//  binkapp
//
//  Created by Sean Williams on 21/01/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Foundation

class BarcodeViewNoBarcode: BarcodeView {
    func configure(viewModel: LoyaltyCardFullDetailsViewModel) {
        cardNumberLabel.text = viewModel.barcodeViewModel.cardNumber
        
        if let plan = viewModel.membershipCard.membershipPlan {
            iconImageView.setImage(forPathType: .membershipPlanAlternativeHero(plan: plan), animated: true)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.layer.cornerRadius = 10
        iconImageView.layer.cornerCurve = .continuous
    }
}
