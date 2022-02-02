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
        guard let membershipPlan = plan else { return }
        
        logoImageView.setImage(forPathType: .membershipPlanIcon(plan: membershipPlan))
        logoImageView.layer.cornerRadius = LayoutHelper.iconCornerRadius
        backgroundColor = .clear
        
        if let planName = membershipPlan.account?.planName {
            let attributes: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.linkTextButtonNormal, .foregroundColor: UIColor.blueAccent]
            let titleAttributedString = NSMutableAttributedString(string: "About \(planName)", attributes: attributes)
            loyaltyPlanButton.setAttributedTitle(titleAttributedString, for: .normal)
        } else {
            loyaltyPlanButton.isHidden = true
        }
    }
}
