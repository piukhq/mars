//
//  LoyaltyPlanView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

enum PlanType {
    case storeCell
    case viewCell
    case linkCell
}

class LoyaltyPlanView: CustomView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(for planType: PlanType, cardType: PlanCardType) {
        configureIcon(for: planType, cardType: cardType)
        configureTitle(for: planType)
        configureDescription(for: planType, cardType: cardType)
    }
    
    private func configureIcon(for planType: PlanType, cardType: PlanCardType) {
        switch planType {
        case .storeCell: iconImageView.image = UIImage(named: "activeStore")
        case .viewCell:
            if cardType == .view || cardType == .link {
                iconImageView.image = UIImage(named: "activeView")
            } else {
                iconImageView.image = UIImage(named: "inactiveView")
            }
        case .linkCell:
            if cardType == .link {
                iconImageView.image = UIImage(named: "activeLink")
            } else {
                iconImageView.image = UIImage(named: "inactiveLink")
            }
        }
    }
    
    private func configureTitle(for planType: PlanType) {
        switch planType {
        case .storeCell: titleLabel.text = "add_join_screen_store_title".localized
        case .viewCell: titleLabel.text = "add_join_screen_view_title".localized
        case .linkCell: titleLabel.text = "add_join_screen_link_title".localized
        }
    }
    
    private func configureDescription(for planType: PlanType, cardType: PlanCardType) {
        switch planType {
            case .storeCell:
            descriptionLabel.text = "add_join_screen_store_description".localized
            case .viewCell:
            descriptionLabel.text = cardType.rawValue > 0 ? "add_join_screen_view_description".localized : "add_join_screen_view_description_inactive".localized
            case .linkCell:
            descriptionLabel.text = cardType.rawValue > 1 ? "add_join_screen_link_description".localized : "add_join_screen_link_description_inactive".localized
        }
    }
    
    override func configureUI() {
        titleLabel.font = UIFont.headline
        descriptionLabel.font = UIFont.bodyTextLarge
    }
}
