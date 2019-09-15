//
//  DebugMenuTableViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 02/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class DebugMenuTableViewCell: UITableViewCell, ReusableView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    func configure(withDebugRow debugRow: DebugMenuRow) {
        titleLabel.text = debugRow.title
        subtitleLabel.text = debugRow.subtitle
        accessoryType = debugRow.action == nil ? .none : .disclosureIndicator
        selectionStyle = debugRow.action == nil ? .none : .default
    }
}
