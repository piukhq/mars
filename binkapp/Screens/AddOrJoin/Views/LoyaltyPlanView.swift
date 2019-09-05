//
//  LoyaltyPlanView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

enum PlanCellType {
    case storeCell
    case viewCell
    case linkCell
}

enum CardType: Int {
    case store = 0
    case view
    case link
}

class LoyaltyPlanView: CustomView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(for planCellType: PlanCellType, cardType: CardType) {
        configureIcon(for: planCellType, cardType: cardType)
        configureTitle(for: planCellType)
        configureDescription(for: planCellType, cardType: cardType)
    }
    
    private func configureIcon(for planCellType: PlanCellType, cardType: CardType) {
        switch planCellType {
        case .storeCell: iconImageView.image = UIImage(named: "activeStore")
        case .viewCell:
            if cardType.rawValue > 0 {
                iconImageView.image = UIImage(named: "activeView")
            } else {
                iconImageView.image = UIImage(named: "inactiveView")
            }
        case .linkCell:
            if cardType.rawValue > 1 {
                iconImageView.image = UIImage(named: "activeLink")
            } else {
                iconImageView.image = UIImage(named: "inactiveLink")
            }
        }
    }
    
    private func configureTitle(for planCellType: PlanCellType) {
        switch planCellType {
        case .storeCell: titleLabel.text = "add_join_screen_store_title".localized
        case .viewCell: titleLabel.text = "add_join_screen_view_title".localized
        case .linkCell: titleLabel.text = "add_join_screen_link_title".localized
        }
    }
    
    private func configureDescription(for planCellType: PlanCellType, cardType: CardType) {
        switch planCellType {
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
