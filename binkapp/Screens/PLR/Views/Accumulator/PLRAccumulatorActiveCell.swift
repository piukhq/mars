//
//  PLRAccumulatorActiveCell.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRAccumulatorCell: PLRBaseCollectionViewCell {
    @IBOutlet weak var innerProgressBar: UIView!
    @IBOutlet weak var outerProgressBar: UIView!
    @IBOutlet weak var innerProgressBarWidthConstraint: NSLayoutConstraint!

    override func configure() {
        super.configure()

        innerProgressBar.layer.cornerRadius = LayoutHelper.PLRCollectionViewCell.Accumulator.progressBarCornerRadius
        innerProgressBar.backgroundColor = .amberPending

        outerProgressBar.layer.cornerRadius = LayoutHelper.PLRCollectionViewCell.Accumulator.progressBarCornerRadius
        outerProgressBar.backgroundColor = .grey10

        innerProgressBarWidthConstraint = innerProgressBar.widthAnchor.constraint(equalTo: outerProgressBar.widthAnchor, multiplier: 0.9)
        innerProgressBarWidthConstraint.isActive = true
    }
}

class PLRAccumulatorActiveCell: PLRAccumulatorCell {
    override func configure() {
        super.configure()
    }
}

extension LayoutHelper {
    struct PLRCollectionViewCell {
        static let infoButtonCornerRadius: CGFloat = 10

        struct Accumulator {
            static let progressBarCornerRadius: CGFloat = 6
        }
    }
}
