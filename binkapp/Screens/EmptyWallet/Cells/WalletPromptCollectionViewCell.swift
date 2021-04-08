//
//  WalletPromptCollectionViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 10/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class WalletPromptCollectionViewCell: WalletCardCollectionViewCell {
    @IBOutlet private weak var brandIconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    
    private lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    private var walletPrompt: WalletPrompt!

    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
    }

    func configureWithWalletPrompt(_ walletPrompt: WalletPrompt) {
        self.walletPrompt = walletPrompt

        setupShadow()
        
        titleLabel.text = walletPrompt.title
        detailLabel.text = walletPrompt.body
        titleLabel.sizeToFit()
        detailLabel.sizeToFit()
        
        if UIDevice.current.isSmallSize {
            titleLabel.font = .walletPromptTitleSmall
            detailLabel.font = .walletPromptBodySmall
        }

        if let iconName = walletPrompt.iconImageName {
            brandIconImageView.image = UIImage(named: iconName)
        }

        containerView.backgroundColor = Current.themeManager.color(for: .walletCardBackground)
        detailLabel.textColor = Current.themeManager.color(for: .text)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }
}
