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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setSeparatorDefaultWidth()
    }

    func configureWithViewModel(_ viewModel: PaymentCardDetailLinkLoyaltyCardCellViewModel, indexPath: IndexPath, delegate: PaymentCardDetailLinkLoyaltyCardCellDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
        tag = indexPath.row

        headerLabel.text = viewModel.headerText
        headerLabel.textColor = Current.themeManager.color(for: .text)
        detailLabel.text = viewModel.detailText
        detailLabel.textColor = Current.themeManager.color(for: .text)
        linkToggle.isOn = viewModel.isLinked
        
        guard let membershipPlan = viewModel.membershipCard.membershipPlan else { return }
        ImageService.getImage(forPathType: .membershipPlanIcon(plan: membershipPlan), traitCollection: traitCollection) { image in
            if self.tag == indexPath.row {
                self.iconImageView.image = image
            }
        }
        selectedBackgroundView = binkTableViewCellSelectedBackgroundView()
    }

    @IBAction private func didToggle() {
        linkToggle.isGradientVisible = linkToggle.isOn
        delegate?.linkedLoyaltyCardCell(self, shouldToggleLinkedStateForMembershipCard: viewModel.membershipCard)
    }
}
