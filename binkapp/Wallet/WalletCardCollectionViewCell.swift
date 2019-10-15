//
//  WalletCardCollectionViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 14/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class WalletCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!

    func setupShadow() {
        containerView.layer.cornerRadius = 8 // to layout helper?
        containerView.layer.masksToBounds = true
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.3
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        clipsToBounds = false
    }
}
