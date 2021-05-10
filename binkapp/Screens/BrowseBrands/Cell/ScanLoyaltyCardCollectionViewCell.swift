//
//  ScanLoyaltyCardCollectionViewCell.swift
//  binkapp
//
//  Created by Sean Williams on 10/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class ScanLoyaltyCardCollectionViewCell: WalletCardCollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupShadow()
        iconImageView.image = Asset.binkIconLogo.image
        CAGradientLayer.makeGradient(for: containerView, firstColor: .binkGradientBlueRight, secondColor: .binkGradientBlueLeft, startPoint: CGPoint(x: 0.7, y: 0.0))
        
        // soryt localized strings
    }
}
