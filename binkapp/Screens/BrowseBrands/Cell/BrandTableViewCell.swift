//
//  BrandTableViewCell.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import SwiftUI

class BrandTableViewCell: UITableViewCell {
    @IBOutlet private weak var labelsStackView: UIStackView!
    @IBOutlet private weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        logoImageView.image = nil
        separatorView.isHidden = false
//        descriptionLabel.isHidden = true
    }
    
//    func configure(plan: CD_MembershipPlan, brandName: String, brandExists: Bool, indexPath: IndexPath) {
//        tag = indexPath.hashValue
//        accessibilityIdentifier = brandName
//
//        logoImageView.backgroundColor = .clear
//        logoImageView.layer.cornerRadius = LayoutHelper.iconCornerRadius
//        ImageService.getImage(forPathType: .membershipPlanIcon(plan: plan), userInterfaceStyle: traitCollection.userInterfaceStyle) { [weak self] image in
//            if self?.tag == indexPath.hashValue {
//                self?.logoImageView.image = image
//            }
//        }
//
//        disclosureIndicatorImageView.tintColor = Current.themeManager.color(for: .text)
//        separatorView.backgroundColor = Current.themeManager.color(for: .divider)
//
//        brandLabel.font = UIFont.subtitle
//        brandLabel.text = brandName
//        brandLabel.textColor = Current.themeManager.color(for: .text)
//
//        let isPLL = plan.featureSet?.planCardType == .link
//        descriptionLabel.isHidden = !isPLL
//        descriptionLabel.font = UIFont.bodyTextSmall
//        descriptionLabel.text = L10n.canBeLinkedDescription
//        descriptionLabel.textColor = Current.themeManager.color(for: .text)
//
//        existingBrandIcon.isHidden = !brandExists
//        existingBrandIcon.tintColor = Current.themeManager.color(for: .text)
//
//        logoImageView.isHidden = true
//        labelsStackView.isHidden = true
//        brandLabel.isHidden = true
//        descriptionLabel.isHidden = true
//        existingBrandIcon.isHidden = true
////        separatorView.isHidden = true
//        disclosureIndicatorImageView.isHidden = true
//    }
//
    func configure(hostingController: UIHostingController<BrowseBrandsListRowView>) {
//        addSubview(hostingController.view)
        labelsStackView.addArrangedSubview(hostingController.view)
//        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            hostingController.view.topAnchor.constraint(equalTo: self.topAnchorr),
//            hostingController.view.leftAnchor.constraint(equalTo: self.leftAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: labelsStackView.widthAnchor),
//            hostingController.view.bottomAnchor.constraint(equalTo: <#T##NSLayoutAnchor<NSLayoutYAxisAnchor>#>)
//            separatorView.topAnchor.constraint(equalTo: hostingController.view.bottomAnchor),
//            self.rightAnchor.constraint(equalTo: hostingController.view.rightAnchor)
        ])
        
        backgroundColor = Current.themeManager.color(for: .viewBackground)
//        separatorView.backgroundColor = Current.themeManager.color(for: .divider)
        separatorView.backgroundColor = .purple

//        logoImageView.isHidden = true
//        labelsStackView.isHidden = true
//        brandLabel.isHidden = true
//        descriptionLabel.isHidden = true
//        existingBrandIcon.isHidden = true
////        separatorView.isHidden = true
//        disclosureIndicatorImageView.isHidden = true
    }
    
    func hideSeparatorView() {
//        separatorView.isHidden = true
    }
}
