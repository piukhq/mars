//
//  BinkFloatingButtons.swift
//  binkapp
//
//  Created by Dorin Pop on 18/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol BinkFloatingButtonsViewDelegate: AnyObject {
    func binkFloatingButtonsPrimaryButtonWasTapped(_ floatingButtons: BinkFloatingButtonsView)
    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkFloatingButtonsView)
}

class BinkFloatingButtonsView: CustomView {
    @IBOutlet weak var primaryButton: BinkGradientButton!
    @IBOutlet weak var secondaryButton: UIButton!
    weak var delegate: BinkFloatingButtonsViewDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
         setGradientBackground(firstColor: .init(white: 255, alpha: 0), secondColor: .init(white: 255, alpha: 1), orientation: .vertical, roundedCorner: false)
    }
    
    func configure(primaryButtonTitle: String?, secondaryButtonTitle: String?) {
        primaryButton.setTitle(primaryButtonTitle, for: .normal)
        primaryButton.isHidden = primaryButtonTitle == nil

        secondaryButton.setTitle(secondaryButtonTitle, for: .normal)
        secondaryButton.isHidden = secondaryButtonTitle == nil
        secondaryButton.titleLabel?.font = .buttonText
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
    struct FloatingButtons {
        static let height: CGFloat = (PillButton.height * 2) + PillButton.verticalSpacing
        static let width: CGFloat = PillButton.width
        static let bottomPadding: CGFloat = PillButton.bottomPadding
    }
}
