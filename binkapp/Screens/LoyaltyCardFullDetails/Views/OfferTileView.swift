//
//  OfferTileView.swift
//  binkapp
//
//  Created by Dorin Pop on 11/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class OfferTileView: CustomView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var offerImageView: UIImageView!
    
    func configure(imageUrl: String) {
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        offerImageView.setImage(forPathType: .membershipPlanOfferTile(url: imageUrl))
        
        DispatchQueue.main.async {
            self.layer.applyDefaultBinkShadow()
        }
    }
}

