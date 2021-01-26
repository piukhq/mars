//
//  PLRAccumulatorActiveCell.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRAccumulatorActiveCell: PLRAccumulatorCell {
    @IBOutlet private weak var earnProgressLabel: UILabel!
    @IBOutlet private weak var earnTargetLabel: UILabel!
    @IBOutlet private weak var earnProgressValueLabel: UILabel!
    @IBOutlet private weak var earnTargetValueLabel: UILabel!

    override func configureWithViewModel(_ viewModel: PLRCellViewModel, tapAction: PLRBaseCollectionViewCell.CellTapAction?) {
        super.configureWithViewModel(viewModel, tapAction: tapAction)

        earnProgressLabel.text = viewModel.earnProgressString
        earnProgressLabel.textColor = Current.themeManager.color(for: .text)
        earnTargetLabel.text = viewModel.earnTargetString
        earnTargetLabel.textColor = Current.themeManager.color(for: .text)
        earnProgressValueLabel.text = viewModel.earnProgressValueString
        earnProgressValueLabel.textColor = Current.themeManager.color(for: .text)
        earnTargetValueLabel.text = viewModel.earnTargetValueString
        earnTargetValueLabel.textColor = Current.themeManager.color(for: .text)
    }
}

extension LayoutHelper {
    enum PLRCollectionViewCell {
        static let infoButtonCornerRadius: CGFloat = 10
        static let accumulatorActiveCellHeight: CGFloat = 188
        static let accumulatorInactiveCellHeight: CGFloat = 170
        static let stampsActiveCellHeight: CGFloat = 200
        static let stampsInactiveCellHeight: CGFloat = 176

        enum Accumulator {
            static let progressBarCornerRadius: CGFloat = 6
        }
    }
}
