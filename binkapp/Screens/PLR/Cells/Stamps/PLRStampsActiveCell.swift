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

    override func configureWithViewModel(_ viewModel: PLRCellViewModel) {
        super.configureWithViewModel(viewModel)

        earnProgressLabel.text = viewModel.earnProgressString
        earnProgressValueLabel.text = viewModel.earnProgressValueString
    }
}
