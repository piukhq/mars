//
//  PaymentCardDetailLoyaltyCardStatusCell.swift
//  binkapp
//
//  Created by Nick Farrant on 05/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentCardDetailLoyaltyCardStatusCell: PaymentCardDetailTableViewCell {
    @IBOutlet private weak var statusLabel: UILabel!

    private var viewModel: PaymentCardDetailLoyaltyCardStatusCellViewModel!

    func configureWithViewModel(_ viewModel: PaymentCardDetailLoyaltyCardStatusCellViewModel) {
        headerLabel.text = viewModel.headerText
        detailLabel.text = viewModel.detailText
        if let iconImageUrl = viewModel.iconUrl {
            iconImageView.af_setImage(withURL: iconImageUrl)
        }
        statusLabel.text = viewModel.statusText
        statusLabel.textColor = textColor(forStatus: viewModel.status)
    }

    private func textColor(forStatus status: CD_MembershipCardStatus?) -> UIColor {
        switch status?.status {
        case .pending:
            return .amberPending
        default:
            return .redAttention
        }
    }
}
