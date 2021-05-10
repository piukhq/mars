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
        
        titleLabel.text = L10n.scanButtonTitle
        subtitleLabel.text = L10n.scanUttonSubtitle
        iconImageView.image = Asset.scanQuick.image
        CAGradientLayer.makeGradient(for: contentView, firstColor: .binkGradientBlueRight, secondColor: .binkGradientBlueLeft, startPoint: CGPoint(x: 1.0, y: 0.0))
        
        
    }
}
