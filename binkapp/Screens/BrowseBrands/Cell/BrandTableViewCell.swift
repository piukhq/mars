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
    
    func configure(plan: CD_MembershipPlan, brandName: String, description: Bool = false) {
        logoImageView.setImage(forPathType: .membershipPlanIcon(plan: plan))

        brandLabel.font = UIFont.subtitle
        brandLabel.text = brandName
        
        descriptionLabel.isHidden = !description
        descriptionLabel.font = UIFont.bodyTextSmall
        descriptionLabel.text = "can_be_linked_description".localized
    }
    
    func hideSeparatorView() {
        separatorView.isHidden = true
    }
}
