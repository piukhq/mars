//
//  DebugMenuTableViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 02/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class DebugMenuTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    func configure(withDebugRow debugRow: DebugMenuRow) {
        backgroundColor = .clear
        titleLabel.text = debugRow.title
        titleLabel.textColor = Current.themeManager.color(for: .text)
        subtitleLabel.text = debugRow.subtitle
        subtitleLabel.textColor = Current.themeManager.color(for: .text)
        accessoryType = debugRow.action == nil ? .none : .disclosureIndicator
        selectionStyle = debugRow.action == nil ? .none : .default
    }
}
