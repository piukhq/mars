//
//  PLRStampsActiveCell.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRStampsActiveCell: PLRStampsCell {
    @IBOutlet private weak var earnProgressLabel: UILabel!
    @IBOutlet private weak var earnProgressValueLabel: UILabel!

    override func configureWithViewModel(_ viewModel: PLRCellViewModel, tapAction: PLRBaseCollectionViewCell.CellTapAction?) {
        super.configureWithViewModel(viewModel, tapAction: tapAction)
        earnProgressLabel.text = viewModel.earnProgressString
        earnProgressLabel.textColor = Current.themeManager.color(for: .text)
        earnProgressValueLabel.text = viewModel.earnProgressValueString
        earnProgressValueLabel.textColor = Current.themeManager.color(for: .text)
    }
}
