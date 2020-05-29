//
//  PLRAccumulatorInactiveCell.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRAccumulatorInactiveCell: PLRAccumulatorCell {
    @IBOutlet private weak var timeDateLabel: UILabel!

    override func configureWithViewModel(_ viewModel: PLRCellViewModel, tapAction: PLRBaseCollectionViewCell.CellTapAction?) {
        super.configureWithViewModel(viewModel, tapAction: tapAction)
        timeDateLabel.text = viewModel.dateText
    }
}
