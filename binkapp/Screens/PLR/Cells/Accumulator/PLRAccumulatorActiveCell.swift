//
//  PLRAccumulatorActiveCell.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRAccumulatorActiveCell: PLRAccumulatorCell {
    @IBOutlet weak var earnProgressLabel: UILabel!
    @IBOutlet weak var earnTargetLabel: UILabel!
    @IBOutlet weak var earnProgressValueLabel: UILabel!
    @IBOutlet weak var earnTargetValueLabel: UILabel!

    override func configureWithViewModel(_ viewModel: PLRCellViewModel) {
        super.configureWithViewModel(viewModel)

        earnProgressLabel.text = viewModel.earnProgressString
        earnTargetLabel.text = viewModel.earnTargetString
        earnProgressValueLabel.text = viewModel.earnProgressValueString
        earnTargetValueLabel.text = viewModel.earnTargetValueString
    }
}

extension LayoutHelper {
    struct PLRCollectionViewCell {
        static let infoButtonCornerRadius: CGFloat = 10
        static let accumulatorActiveCellHeight: CGFloat = 188
        static let accumulatorInactiveCellHeight: CGFloat = 170
        static let stampsActiveCellHeight: CGFloat = 194
        static let stampsInactiveCellHeight: CGFloat = 176

        struct Accumulator {
            static let progressBarCornerRadius: CGFloat = 6
        }
    }
}
