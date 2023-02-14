//
//  BarcodeViewWide.swift
//  binkapp
//
//  Created by Sean Williams on 12/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit
import SwiftUI

class BarcodeViewWide: BarcodeView {
    func configure(viewModel: LoyaltyCardFullDetailsViewModel) {
        cardNumberLabel.text = viewModel.barcodeViewModel.cardNumber
        
        if let plan = viewModel.membershipCard.membershipPlan {
            iconImageView.setImage(forPathType: .membershipPlanIcon(plan: plan), animated: true)
        }
        
        switch viewModel.barcodeViewModel.barcodeType {
        case .aztec, .dataMatrix, .qr:
            barcodeImageView.isHidden = true
            
            let hostingController = UIHostingController(rootView: BarcodeImageView(viewModel: viewModel.barcodeViewModel, alwaysShowBarCode: viewModel.barcodeViewModel.alwaysShowBarcode))
            if let swiftUIView = hostingController.view {
                swiftUIView.translatesAutoresizingMaskIntoConstraints = false
                swiftUIView.backgroundColor = .clear
                addSubview(swiftUIView)
                
                NSLayoutConstraint.activate([
                    swiftUIView.leadingAnchor.constraint(equalTo: barcodeImageContainer.leadingAnchor),
                    swiftUIView.trailingAnchor.constraint(equalTo: barcodeImageContainer.trailingAnchor),
                    swiftUIView.topAnchor.constraint(equalTo: barcodeImageContainer.topAnchor),
                    swiftUIView.bottomAnchor.constraint(equalTo: barcodeImageContainer.bottomAnchor)
                ])
            }
        default:
            barcodeImageContainer.isHidden = true
            
            if let barcodeImage = viewModel.barcodeViewModel.barcodeImage(withSize: barcodeImageView.frame.size) {
                barcodeImageView.image = barcodeImage
            }
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
