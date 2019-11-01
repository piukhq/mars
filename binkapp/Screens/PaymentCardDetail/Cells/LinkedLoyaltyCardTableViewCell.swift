//
//  LinkedLoyaltyCardTableViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 07/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import AlamofireImage

protocol LinkedLoyaltyCardCellDelegate: AnyObject {
    func linkedLoyaltyCardCell(_ cell: LinkedLoyaltyCardTableViewCell, shouldToggleLinkedStateForMembershipCard membershipCard: CD_MembershipCard)
}

class LinkedLoyaltyCardTableViewCell: UITableViewCell {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var pointsValueLabel: UILabel!
    @IBOutlet private weak var linkToggle: BinkSwitch!

    private var viewModel: LinkedLoyaltyCellViewModel!
    private weak var delegate: LinkedLoyaltyCardCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureWithViewModel(_ viewModel: LinkedLoyaltyCellViewModel, delegate: LinkedLoyaltyCardCellDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate

        companyNameLabel.text = viewModel.companyNameText
        if let iconImageUrl = viewModel.iconUrl {
            iconImageView.af_setImage(withURL: iconImageUrl)
        }

        linkToggle.isOn = viewModel.isLinked
        pointsValueLabel.text = viewModel.pointsValueText
    }

    @IBAction private func didToggle() {
        linkToggle.isGradientVisible = linkToggle.isOn
        delegate?.linkedLoyaltyCardCell(self, shouldToggleLinkedStateForMembershipCard: viewModel.membershipCard)
    }
    
}
