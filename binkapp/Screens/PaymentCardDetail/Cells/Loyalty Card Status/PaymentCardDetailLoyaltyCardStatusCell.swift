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
        headerLabel.textColor = Current.themeManager.color(for: .text)
        detailLabel.text = viewModel.detailText
        detailLabel.textColor = Current.themeManager.color(for: .text)
        statusLabel.text = viewModel.statusText
        statusLabel.textColor = textColor(forStatus: viewModel.status)
        
        guard let membershipPlan = viewModel.membershipCard.membershipPlan else { return }
        iconImageView.setImage(forPathType: .membershipPlanIcon(plan: membershipPlan))
    }
    
    func configure(with paymentCard: CD_PaymentCard) {
        headerLabel.text = paymentCard.card?.nameOnCard
        detailLabel.text = String(format: "pll_screen_card_ending".localized, paymentCard.card?.lastFour ?? "")
        statusLabel.text = paymentCard.paymentCardStatus.rawValue
        statusLabel.textColor = .amberPending
        
        var paymentCardProviderImageName: String
        switch PaymentCardType.type(from: paymentCard.card?.firstSix) {
        case .visa:
            paymentCardProviderImageName = "visalogoContainer"
        case .amex:
            paymentCardProviderImageName = "americanexpresslogoContainer"
        case .mastercard:
            paymentCardProviderImageName = "mastercardlogoContainer"
        default: return
        }
        iconImageView.image = UIImage(named: paymentCardProviderImageName)
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
