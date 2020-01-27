//
//  BinkPrimarySecondaryButtonView.swift
//  binkapp
//
//  Created by Dorin Pop on 18/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol BinkPrimarySecondaryButtonViewDelegate: AnyObject {
    func binkFloatingButtonsPrimaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView)
    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView)
}

class BinkPrimarySecondaryButtonView: CustomView {
    @IBOutlet weak var primaryButton: BinkGradientButton!
    @IBOutlet weak var secondaryButton: BinkTrackableButton!
    weak var delegate: BinkPrimarySecondaryButtonViewDelegate?

    private var isFloating: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isFloating {
            setGradientBackground(firstColor: .init(white: 255, alpha: 0), secondColor: .init(white: 255, alpha: 1), orientation: .vertical, roundedCorner: false)
        }
    }
    
    func configure(primaryButtonTitle: String?, secondaryButtonTitle: String?, floating: Bool = false) {
        isFloating = floating
        primaryButton.setTitle(primaryButtonTitle, for: .normal)
        primaryButton.isHidden = primaryButtonTitle == nil

        secondaryButton.setTitle(secondaryButtonTitle, for: .normal)
        secondaryButton.isHidden = secondaryButtonTitle == nil
        secondaryButton.titleLabel?.font = .buttonText
        layoutSubviews()
    }
    
    override func configureUI() {
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    // MARK: - Actions
    
    @IBAction func primaryButtonWasTapped(_ sender: Any) {
        delegate?.binkFloatingButtonsPrimaryButtonWasTapped(self)
    }
    
    @IBAction func secondaryButtonWasTapped(_ sender: Any) {
        delegate?.binkFloatingButtonsSecondaryButtonWasTapped(self)
    }
}

extension LayoutHelper {
    struct PrimarySecondaryButtonView {
        static let height: CGFloat = (PillButton.height * 2) + PillButton.verticalSpacing + PillButton.bottomPadding
        static let bottomPadding: CGFloat = 16
    }
}
