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
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        clipsToBounds = false
        layer.applyDefaultBinkShadow()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
