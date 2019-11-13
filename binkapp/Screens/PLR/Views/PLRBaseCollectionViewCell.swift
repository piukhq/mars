//
//  PLRBaseCollectionViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRBaseCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var infoButton: UIButton!

    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }

    func configure() {
        setupShadow()

        infoButton.layer.cornerRadius = LayoutHelper.PLRCollectionViewCell.infoButtonCornerRadius
    }

    private func setupShadow() {
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        clipsToBounds = false
        layer.applyDefaultBinkShadow()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
