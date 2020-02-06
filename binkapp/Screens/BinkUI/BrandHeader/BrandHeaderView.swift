//
//  BrandHeaderView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol LoyaltyButtonDelegate: class {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView)
}

class BrandHeaderView: CustomView {
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var loyaltyPlanButton: BinkInfoButton!
    
    private weak var delegate: LoyaltyButtonDelegate?
    
    @IBAction func loyaltyButtonAction(_ sender: Any) {
        delegate?.brandHeaderViewWasTapped(self)
    }
    
    func configure(plan: CD_MembershipPlan?, delegate: LoyaltyButtonDelegate) {
        self.delegate = delegate
        guard let membershipPlan = plan else { return }
        
        logoImageView.setImage(forPathType: .membershipPlanIcon(plan: membershipPlan))
        
        if let planNameCard = membershipPlan.account?.planNameCard {
            loyaltyPlanButton.setTitle(planNameCard + " info", for: .normal)
            loyaltyPlanButton.setImage(UIImage(named: "iconsChevronRight")?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            loyaltyPlanButton.isHidden = true
        }
    }
}
