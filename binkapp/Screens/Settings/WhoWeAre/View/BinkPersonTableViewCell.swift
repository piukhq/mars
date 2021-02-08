//
//  binkPersonTableViewCell.swift
//  binkapp
//
//  Created by Sean Williams on 07/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class BinkPersonTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setSeparatorDefaultWidth()
    }

    func configure(with teamMember: BinkTeamMember) {
        backgroundColor = .clear
        titleLabel.text = teamMember.name
        titleLabel.textColor = Current.themeManager.color(for: .text)
        titleLabel.font = UIFont.bodyTextLarge
        titleLabel.textColor = Current.themeManager.color(for: .text)
    }
}
