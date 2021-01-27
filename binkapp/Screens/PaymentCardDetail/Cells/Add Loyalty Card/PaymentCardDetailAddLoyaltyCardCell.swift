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
        headerLabel.textColor = Current.themeManager.color(for: .text)
        detailLabel.text = viewModel.detailText
        detailLabel.textColor = Current.themeManager.color(for: .text)
        addCardButton.configure(title: "pcd_add_card_button_title".localized, hasShadow: false)
        iconImageView.setIconImage(membershipPlan: viewModel.membershipPlan)
        selectedBackgroundView = binkSelectedView()
    }

    @IBAction private func handleAddCardButtonPress() {
        viewModel.toAddOrJoin()
    }
}
