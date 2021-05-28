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

    override func prepareForReuse() {
        super.prepareForReuse()
        setSeparatorDefaultWidth()
    }
    
    func configureWithViewModel(_ viewModel: PaymentCardDetailLoyaltyCardStatusCellViewModel, indexPath: IndexPath) {
        headerLabel.text = viewModel.headerText
        headerLabel.textColor = Current.themeManager.color(for: .text)
        detailLabel.text = viewModel.detailText
        detailLabel.textColor = Current.themeManager.color(for: .text)
        statusLabel.text = viewModel.statusText
        statusLabel.textColor = textColor(forStatus: viewModel.status)
        tag = indexPath.row
        
        guard let membershipPlan = viewModel.membershipCard.membershipPlan else { return }
        ImageService.getImage(forPathType: .membershipPlanIcon(plan: membershipPlan), traitCollection: traitCollection) { [weak self] image in
            if self?.tag == indexPath.row {
                self?.iconImageView.image = image
            }
        }
        selectedBackgroundView = binkTableViewCellSelectedBackgroundView()
    }
    
    func configure(with paymentCard: CD_PaymentCard) {
        headerLabel.text = paymentCard.card?.nameOnCard
        detailLabel.text = L10n.pllScreenCardEnding(paymentCard.card?.lastFour ?? "")
        statusLabel.text = paymentCard.paymentCardStatus.rawValue
        statusLabel.textColor = .amberPending
        headerLabel.textColor = Current.themeManager.color(for: .text)
        detailLabel.textColor = Current.themeManager.color(for: .text)
        iconImageView.setImage(forPaymentCardFirstSix: paymentCard.card?.firstSix ?? "")
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
