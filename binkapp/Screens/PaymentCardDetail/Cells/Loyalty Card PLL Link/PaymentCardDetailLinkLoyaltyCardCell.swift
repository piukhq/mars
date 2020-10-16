//
//  PaymentCardDetailLinkLoyaltyCardCell.swift
//  binkapp
//
//  Created by Nick Farrant on 07/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol PaymentCardDetailLinkLoyaltyCardCellDelegate: AnyObject {
    func linkedLoyaltyCardCell(_ cell: PaymentCardDetailLinkLoyaltyCardCell, shouldToggleLinkedStateForMembershipCard membershipCard: CD_MembershipCard)
}

class PaymentCardDetailLinkLoyaltyCardCell: PaymentCardDetailTableViewCell {
    @IBOutlet private weak var linkToggle: BinkSwitch!

    private var viewModel: PaymentCardDetailLinkLoyaltyCardCellViewModel!
    private weak var delegate: PaymentCardDetailLinkLoyaltyCardCellDelegate?

    func configureWithViewModel(_ viewModel: PaymentCardDetailLinkLoyaltyCardCellViewModel, delegate: PaymentCardDetailLinkLoyaltyCardCellDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate

        headerLabel.text = viewModel.headerText
        detailLabel.text = viewModel.detailText
        linkToggle.isOn = viewModel.isLinked
        guard let membershipPlan = viewModel.membershipCard.membershipPlan else { return }
        iconImageView.setImage(forPathType: .membershipPlanIcon(plan: membershipPlan))
    }

    @IBAction private func didToggle() {
        linkToggle.isGradientVisible = linkToggle.isOn
        delegate?.linkedLoyaltyCardCell(self, shouldToggleLinkedStateForMembershipCard: viewModel.membershipCard)
    }
    
}
