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
    @IBOutlet weak var voucherAmountLabel: UILabel!
    @IBOutlet weak var voucherDescriptionLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!

    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }

    func configureWithViewModel(_ viewModel: PLRCellViewModel) {
        setupShadow()

        voucherAmountLabel.text = viewModel.voucherAmountText
        headlineLabel.text = viewModel.headlineText
    }

    private func setupShadow() {
        backgroundColor = .clear
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 8
        clipsToBounds = false
        layer.applyDefaultBinkShadow()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
