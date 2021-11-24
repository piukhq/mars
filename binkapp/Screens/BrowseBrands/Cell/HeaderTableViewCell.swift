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
    @IBOutlet weak var stackView: UIStackView!
    
    lazy var scanLoyaltyCardButton: ScanLoyaltyCardButton = {
        let cell: ScanLoyaltyCardButton = .fromNib()
        cell.frame = CGRect(x: 0, y: 0, width: frame.width, height: 88)
        return cell
    }()
    
    private lazy var spacer: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 10))
    }()
    
    func configure(section: Int, viewModel: BrowseBrandsViewModel) {
        titleLabel.text = viewModel.getSectionTitleText(section: section)
        titleLabel.font = .headline
        titleLabel.textColor = Current.themeManager.color(for: .text)
        descriptionLabel.attributedText = viewModel.getSectionDescriptionText(section: section)
        descriptionLabel.textColor = Current.themeManager.color(for: .text)
        selectedBackgroundView = binkTableViewCellSelectedBackgroundView()
        
        if section == 0 {
            stackView.insertArrangedSubview(scanLoyaltyCardButton, at: 0)
            stackView.insertArrangedSubview(spacer, at: 1)
        }
    }
}
