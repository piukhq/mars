//
//  PaymentCardDetailAddLoyaltyCardCell.swift
//  binkapp
//
//  Created by Nick Farrant on 05/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentCardDetailAddLoyaltyCardCell: PaymentCardDetailTableViewCell {
    @IBOutlet private weak var addCardButton: UIButton!

    private var viewModel: PaymentCardDetailAddLoyaltyCardCellViewModel!

    func configureWithViewModel(_ viewModel: PaymentCardDetailAddLoyaltyCardCellViewModel) {
        headerLabel.text = viewModel.headerText
        detailLabel.text = viewModel.detailText
        if let iconImageUrl = viewModel.iconUrl {
            iconImageView.af_setImage(withURL: iconImageUrl)
        }
    }
}
