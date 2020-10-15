//
//  PaymentCardDetailLoyaltyCardStatusCell.swift
//  binkapp
//
//  Created by Nick Farrant on 05/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class CardDetailCardStatusCell: PaymentCardDetailTableViewCell {
    @IBOutlet private weak var statusLabel: UILabel!

    private var viewModel: CardDetailCardStatusCellViewModel!

    func configureWithViewModel(_ viewModel: CardDetailCardStatusCellViewModel) {
        headerLabel.text = viewModel.headerText
        detailLabel.text = viewModel.detailText
        statusLabel.text = viewModel.statusText
        statusLabel.textColor = textColor(forStatus: viewModel.membershipCardStatus)
        
        guard let membershipPlan = viewModel.membershipCard?.membershipPlan else { return }
        iconImageView.setImage(forPathType: .membershipPlanIcon(plan: membershipPlan))
    }

    private func textColor(forStatus status: MembershipCardStatus?) -> UIColor {
        switch status {
        case .pending:
            return .amberPending
        default:
            return .redAttention
        }
    }
}
