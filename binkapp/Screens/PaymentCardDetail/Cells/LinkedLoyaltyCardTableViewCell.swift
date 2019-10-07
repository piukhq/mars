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
    func linkedLoyaltyCardCell(_ cell: LinkedLoyaltyCardTableViewCell, didToggleLinkedState isOn: Bool, forMembershipCard membershipCard: CD_MembershipCard)
}

class LinkedLoyaltyCardTableViewCell: UITableViewCell {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var pointsValueLabel: UILabel!
    @IBOutlet private weak var linkToggle: UISwitch!

    private var membershipCard: CD_MembershipCard!
    private weak var delegate: LinkedLoyaltyCardCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureWithMembershipCard(_ membershipCard: CD_MembershipCard, isLinked: Bool, delegate: LinkedLoyaltyCardCellDelegate?) {
        self.membershipCard = membershipCard
        self.delegate = delegate
        
        companyNameLabel.text = membershipCard.membershipPlan?.account?.companyName

        if let iconImage = membershipCard.membershipPlan?.firstIconImage(),
            let urlString = iconImage.url,
            let imageURL = URL(string: urlString) {
            iconImageView.af_setImage(withURL: imageURL)
        }

        linkToggle.isOn = isLinked
    }

    @IBAction private func didToggle() {
        delegate?.linkedLoyaltyCardCell(self, didToggleLinkedState: linkToggle.isOn, forMembershipCard: membershipCard)
    }
    
}
