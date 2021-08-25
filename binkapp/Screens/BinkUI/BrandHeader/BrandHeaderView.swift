//
//  BrandHeaderView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol LoyaltyButtonDelegate: AnyObject {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView)
}

class BrandHeaderView: CustomView {
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet weak var loyaltyPlanButton: BinkInfoButton!
    
    private weak var delegate: LoyaltyButtonDelegate?
    
    @IBAction func loyaltyButtonAction(_ sender: Any) {
        delegate?.brandHeaderViewWasTapped(self)
    }
    
    func configure(plan: CD_MembershipPlan?, delegate: LoyaltyButtonDelegate) {
        self.delegate = delegate
        logoImageView.backgroundColor = .clear
        view.backgroundColor = .clear
        guard let membershipPlan = plan else { return }
        
        logoImageView.setImage(forPathType: .membershipPlanIcon(plan: membershipPlan))
        
        if let planName = membershipPlan.account?.planName {
            loyaltyPlanButton.setTitle("\(planName) info", for: .normal)
            loyaltyPlanButton.setImage(Asset.iconsChevronRight.image.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            loyaltyPlanButton.isHidden = true
        }
    }
}
