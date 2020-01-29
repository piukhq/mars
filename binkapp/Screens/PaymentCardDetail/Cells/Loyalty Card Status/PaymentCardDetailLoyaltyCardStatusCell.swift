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
        statusLabel.text = viewModel.statusText
        statusLabel.textColor = textColor(forStatus: viewModel.status)
        
        guard let membershipPlan = viewModel.membershipCard.membershipPlan else { return }
        iconImageView.setImage(forPathType: .icon(plan: membershipPlan))
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
