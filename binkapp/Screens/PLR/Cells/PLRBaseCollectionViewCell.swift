//
//  PLRBaseCollectionViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRBaseCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var voucherAmountLabel: UILabel!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var voucherDescriptionLabel: UILabel!
    
    typealias CellTapAction = () -> Void
    private var tapAction: CellTapAction?

    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }

    func configureWithViewModel(_ viewModel: PLRCellViewModel, tapAction: CellTapAction?) {
        self.tapAction = tapAction
        setupShadow()

        voucherAmountLabel.text = viewModel.voucherAmountText
        voucherDescriptionLabel.text = viewModel.voucherDescriptionText
        headlineLabel.text = viewModel.headlineText
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTapGesture() {
        tapAction?()
    }

    private func setupShadow() {
        backgroundColor = .clear
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 8
        clipsToBounds = false
        layer.applyDefaultBinkShadow()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

extension PLRBaseCollectionViewCell {
    static func nibForCellType<T: PLRBaseCollectionViewCell>(_ cellType: T.Type) -> T {
        let cell: T = .fromNib()
        return cell
    }
}
