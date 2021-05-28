//
//  BrandTableViewCell.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class BrandTableViewCell: UITableViewCell {
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var labelsStackView: UIStackView!
    @IBOutlet private weak var brandLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var existingBrandIcon: UIImageView!
    @IBOutlet private weak var disclosureIndicatorImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
        separatorView.isHidden = false
        descriptionLabel.isHidden = true
    }
    
    func configure(plan: CD_MembershipPlan, brandName: String, brandExists: Bool, indexPath: IndexPath) {
        tag = indexPath.hashValue
        accessibilityIdentifier = brandName

        logoImageView.backgroundColor = .clear
        ImageService.getImage(forPathType: .membershipPlanIcon(plan: plan), traitCollection: traitCollection) { [weak self] image in
            if self?.tag == indexPath.hashValue {
                self?.logoImageView.image = image
            }
        }
        backgroundColor = Current.themeManager.color(for: .viewBackground)
        
        disclosureIndicatorImageView.tintColor = Current.themeManager.color(for: .text)
        separatorView.backgroundColor = Current.themeManager.color(for: .divider)
        
        brandLabel.font = UIFont.subtitle
        brandLabel.text = brandName
        brandLabel.textColor = Current.themeManager.color(for: .text)

        let isPLL = plan.featureSet?.planCardType == .link
        descriptionLabel.isHidden = !isPLL
        descriptionLabel.font = UIFont.bodyTextSmall
        descriptionLabel.text = L10n.canBeLinkedDescription
        descriptionLabel.textColor = Current.themeManager.color(for: .text)

        existingBrandIcon.isHidden = !brandExists
        existingBrandIcon.tintColor = Current.themeManager.color(for: .text)
    }
    
    func hideSeparatorView() {
        separatorView.isHidden = true
    }
}
