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
    
    func configure(for planType: PlanType, cardType: CD_FeatureSet.PlanCardType) {
        configureIcon(for: planType, cardType: cardType)
        configureTitle(for: planType)
        configureDescription(for: planType, cardType: cardType)
        view.backgroundColor = .clear
        titleLabel.textColor = Current.themeManager.color(for: .text)
        descriptionLabel.textColor = Current.themeManager.color(for: .text)
    }
    
    private func configureIcon(for planType: PlanType, cardType: CD_FeatureSet.PlanCardType) {
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
        case .storeCell: titleLabel.text = L10n.addJoinScreenStoreTitle
        case .viewCell: titleLabel.text = L10n.addJoinScreenViewTitle
        case .linkCell: titleLabel.text = L10n.addJoinScreenLinkTitle
        }
    }
    
    private func configureDescription(for planType: PlanType, cardType: CD_FeatureSet.PlanCardType) {
        switch planType {
        case .storeCell:
            descriptionLabel.text = L10n.addJoinScreenStoreDescription
        case .viewCell:
            descriptionLabel.text = cardType.rawValue > 0 ? L10n.addJoinScreenViewDescription : L10n.addJoinScreenViewDescriptionInactive
        case .linkCell:
            descriptionLabel.text = cardType.rawValue > 1 ? L10n.addJoinScreenLinkDescription : L10n.addJoinScreenLinkDescriptionInactive
        }
    }
    
    override func configureUI() {
        titleLabel.font = UIFont.headline
        descriptionLabel.font = UIFont.addOrJoinBodyText
    }
}
