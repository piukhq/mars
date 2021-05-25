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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setSeparatorDefaultWidth()
    }

    func configureWithViewModel(_ viewModel: PaymentCardDetailAddLoyaltyCardCellViewModel, indexPath: IndexPath) {
        self.viewModel = viewModel
        tag = indexPath.row
        headerLabel.text = viewModel.headerText
        headerLabel.textColor = Current.themeManager.color(for: .text)
        detailLabel.text = viewModel.detailText
        detailLabel.textColor = Current.themeManager.color(for: .text)
        addCardButton.configure(title: L10n.pcdAddCardButtonTitle, hasShadow: false)
        ImageService.getImage(forPathType: .membershipPlanIcon(plan: viewModel.membershipPlan), traitCollection: traitCollection) { [weak self] image in
            if self?.tag == indexPath.row {
                self?.iconImageView.image = image
            }
        }
        selectedBackgroundView = binkTableViewCellSelectedBackgroundView()
    }

    @IBAction private func handleAddCardButtonPress() {
        viewModel.toAddOrJoin()
    }
}
