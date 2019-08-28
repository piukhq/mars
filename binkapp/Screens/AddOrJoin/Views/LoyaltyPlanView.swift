//
//  LoyaltyPlanView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

enum PlanType {
    case store
    case view
    case link
}

class LoyaltyPlanView: CustomView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(for planType: PlanType, cardType: Int) {
        configureIcon(for: planType, cardType: cardType)
        configureTitle(for: planType)
        configureDescription(for: planType)
    }
    
    private func configureIcon(for planType: PlanType, cardType: Int) {
        switch planType {
        case .store: iconImageView.image = UIImage(named: "activeStore")
        case .view:
            if cardType > 0 {
                iconImageView.image = UIImage(named: "activeView")
            } else {
                iconImageView.image = UIImage(named: "inactiveView")
            }
        case .link:
            if cardType > 1 {
                iconImageView.image = UIImage(named: "activeLink")
            } else {
                iconImageView.image = UIImage(named: "inactiveLink")
            }
        }
    }
    
    private func configureTitle(for planType: PlanType) {
        switch planType {
        case .store: titleLabel.text = "add_join_screen_store_title".localized
        case .view: titleLabel.text = "add_join_screen_view_title".localized
        case .link: titleLabel.text = "add_join_screen_link_title".localized
        }
    }
    
    private func configureDescription(for planType: PlanType) {
        switch planType {
        case .store: descriptionLabel.text = "add_join_screen_store_description".localized
        case .view: descriptionLabel.text = "add_join_screen_view_description".localized
        case .link: descriptionLabel.text = "add_join_screen_link_description".localized
        }
    }
    
    override func configureUI() {
        titleLabel.font = UIFont.headline
        descriptionLabel.font = UIFont.bodyTextLarge
    }
}
