//
//  BrandHeaderView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol LoyaltyButtonDelegate {
    func brandHeaderViewDidTap(_ brandHeaderView: BrandHeaderView)
}

class BrandHeaderView: CustomView {
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var loyaltyPlanButton: BinkInfoButton!
    
    private var delegate: LoyaltyButtonDelegate?
    
    @IBAction func loyaltyButtonAction(_ sender: Any) {
        delegate?.brandHeaderViewDidTap(self)
    }
    
    func configure(imageURLString: String?, loyaltyPlanNameCard: String? = nil, delegate: LoyaltyButtonDelegate) {
        self.delegate = delegate
        
        if let imageURL = imageURLString, let url = URL(string: imageURL) {
            logoImageView.af_setImage(withURL: url)
        }
        
        if let planNameCard = loyaltyPlanNameCard {
            loyaltyPlanButton.setTitle(planNameCard + " info", for: .normal)
            loyaltyPlanButton.setImage(UIImage(named: "iconsChevronRight")?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            loyaltyPlanButton.isHidden = true
        }
    }
}
