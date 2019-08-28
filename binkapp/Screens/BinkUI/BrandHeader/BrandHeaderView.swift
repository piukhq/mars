//
//  BrandHeaderView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol LoyaltyButtonDelegate {
    func buttonWasPressed()
}

class BrandHeaderView: CustomView {
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var loyaltyPlanButton: BinkInfoButton!
    
    private var delegate: LoyaltyButtonDelegate?
    
    @IBAction func loyaltyButtonAction(_ sender: Any) {
        delegate?.buttonWasPressed()
    }
    
    func configure(imageURLString: String, loyaltyPlanNameCard: String? = nil, delegate: LoyaltyButtonDelegate) {
        self.delegate = delegate
        
        if let imageURL = URL(string: imageURLString) {
            logoImageView.af_setImage(withURL: imageURL)
        }
        
        if let planNameCard = loyaltyPlanNameCard {
            loyaltyPlanButton.setTitle(planNameCard + " info", for: .normal)
            loyaltyPlanButton.setImage(UIImage(named: "iconsChevronRight")?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            loyaltyPlanButton.isHidden = true
        }
    }
}
