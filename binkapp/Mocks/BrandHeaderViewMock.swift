//
//  BrandHeaderViewMock.swift
//  binkapp
//
//  Created by Sean Williams on 18/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class BrandHeaderViewMock {
    var loyaltyPlanButton: BinkInfoButton!
    
    func configure(plan: MembershipPlanModel?) {
        guard let membershipPlan = plan else { return }
        
        loyaltyPlanButton = BinkInfoButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        if let planName = membershipPlan.account?.planName {
            loyaltyPlanButton.setTitle("\(planName) info", for: .normal)
            loyaltyPlanButton.setImage(UIImage(named: "iconsChevronRight")?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            loyaltyPlanButton.isHidden = true
        }
    }
}
