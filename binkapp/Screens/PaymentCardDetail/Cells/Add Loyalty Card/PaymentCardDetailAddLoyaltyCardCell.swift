//
//  PaymentCardDetailAddLoyaltyCardCell.swift
//  binkapp
//
//  Created by Nick Farrant on 05/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentCardDetailAddLoyaltyCardCell: PaymentCardDetailTableViewCell {
    @IBOutlet private weak var addCardButton: BinkMiniGradientButton!

    private var viewModel: PaymentCardDetailAddLoyaltyCardCellViewModel!

    func configureWithViewModel(_ viewModel: PaymentCardDetailAddLoyaltyCardCellViewModel) {
        self.viewModel = viewModel
        headerLabel.text = viewModel.headerText
        detailLabel.text = viewModel.detailText
        if let iconImageUrl = viewModel.iconUrl {
            iconImageView.af_setImage(withURL: iconImageUrl)
        }
        addCardButton.setTitle("Add card", for: .normal)
    }

    @IBAction private func handleAddCardButtonPress() {
        viewModel.toAddOrJoin()
    }
}
