///
//  PLRStampsInactiveCell.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRStampsInactiveCell: PLRStampsCell {
    @IBOutlet private weak var timeDateLabel: UILabel!

    override func configureWithViewModel(_ viewModel: PLRCellViewModel) {
        super.configureWithViewModel(viewModel)
        timeDateLabel.text = viewModel.dateText
    }
}
