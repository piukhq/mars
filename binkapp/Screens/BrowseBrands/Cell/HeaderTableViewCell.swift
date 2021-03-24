//
//  HeaderTableViewCell.swift
//  binkapp
//
//  Created by Sean Williams on 16/03/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    func configure(section: Int, viewModel: BrowseBrandsViewModel) {
        titleLabel.text = viewModel.getSectionTitleText(section: section)
        titleLabel.font = .headline
        titleLabel.textColor = Current.themeManager.color(for: .text)
        descriptionLabel.attributedText = viewModel.getSectionDescriptionText(section: section)
        descriptionLabel.textColor = Current.themeManager.color(for: .text)
        selectedBackgroundView = binkTableViewCellSelectedBackgroundView()
    }
}
