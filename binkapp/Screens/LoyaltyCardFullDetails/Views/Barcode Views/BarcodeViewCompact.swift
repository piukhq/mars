//
//  BarcodeViewCompact.swift
//  binkapp
//
//  Created by Sean Williams on 13/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

class BarcodeViewCompact: BarcodeView {
    func configure(membershipCard: CD_MembershipCard) {
        let viewModel = BarcodeViewModel(membershipCard: membershipCard)
        cardNumberLabel.text = viewModel.cardNumber
        
        if let plan = membershipCard.membershipPlan {
            iconImageView.setImage(forPathType: .membershipPlanIcon(plan: plan))
        }
        
        if let barcodeImage = viewModel.barcodeImage(withSize: barcodeImageView.frame.size) {
            barcodeImageView.image = barcodeImage
        }
    }
}
