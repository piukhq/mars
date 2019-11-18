//
//  PLRAccumulatorCell.swift
//  binkapp
//
//  Created by Nick Farrant on 14/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRAccumulatorCell: PLRBaseCollectionViewCell {
    @IBOutlet weak var innerProgressBar: UIView!
    @IBOutlet weak var outerProgressBar: UIView!
    @IBOutlet weak var innerProgressBarWidthConstraint: NSLayoutConstraint!

    override func configureWithViewModel(_ viewModel: PLRCellViewModel) {
        super.configureWithViewModel(viewModel)
        setupUI()

        innerProgressBar.backgroundColor = progressBarColor(forState: viewModel.voucherState)
        innerProgressBarWidthConstraint = innerProgressBar.widthAnchor.constraint(equalTo: outerProgressBar.widthAnchor, multiplier: max(CGFloat.leastNormalMagnitude, CGFloat(viewModel.amountAccumulated)))
        innerProgressBarWidthConstraint.isActive = true
    }

    private func setupUI() {
        innerProgressBar.layer.cornerRadius = LayoutHelper.PLRCollectionViewCell.Accumulator.progressBarCornerRadius
        outerProgressBar.layer.cornerRadius = LayoutHelper.PLRCollectionViewCell.Accumulator.progressBarCornerRadius
        outerProgressBar.backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.15)
    }

    private func progressBarColor(forState state: VoucherState?) -> UIColor {
        switch state {
        case .cancelled:
            return .blue
        case .redeemed:
            return .blueAccent
        case .issued:
            return .greenOk
        case .inProgress:
            return .amberPending
        case .expired, .none:
            return .blueInactive
        }
    }
}
