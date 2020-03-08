//
//  BrandTableViewCell.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import AlamofireImage

class BrandTableViewCell: UITableViewCell {
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var labelsStackView: UIStackView!
    @IBOutlet private weak var brandLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
        separatorView.isHidden = false
        descriptionLabel.isHidden = true
    }
    
    func configure(plan: CD_MembershipPlan, brandName: String) {
        logoImageView.setImage(forPathType: .membershipPlanIcon(plan: plan))

        brandLabel.font = UIFont.subtitle
        brandLabel.text = brandName

        let isPLL = plan.featureSet?.planCardType == .link
        descriptionLabel.isHidden = !isPLL
        descriptionLabel.font = UIFont.bodyTextSmall
        descriptionLabel.text = "can_be_linked_description".localized
    }
    
    func hideSeparatorView() {
        separatorView.isHidden = true
    }
}
