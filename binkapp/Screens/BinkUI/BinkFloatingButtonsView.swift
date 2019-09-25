//
//  BinkFloatingButtons.swift
//  binkapp
//
//  Created by Dorin Pop on 18/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol BinkFloatingButtonsViewDelegate {
    func binkFloatingButtonsPrimaryButtonWasTapped(_ floatingButtons: BinkFloatingButtonsView)
    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkFloatingButtonsView)
}

class BinkFloatingButtonsView: CustomView {
    @IBOutlet weak var mainButton: BinkGradientButton!
    @IBOutlet weak var secondaryButton: UIButton!
    var delegate: BinkFloatingButtonsViewDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
         setGradientBackground(firstColor: .init(white: 255, alpha: 0), secondColor: .init(white: 255, alpha: 1), orientation: .vertical, roundedCorner: false)
    }
    
    func configure(mainButtonTitle: String?, secondaryButtonTitle: String?) {
        if mainButtonTitle != nil {
            mainButton.setTitle(mainButtonTitle, for: .normal)
        } else {
            mainButton.isHidden = true
        }
        
        if secondaryButtonTitle != nil {
            secondaryButton.setTitle(secondaryButtonTitle, for: .normal)
        } else {
            secondaryButton.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction func primaryButtonWasTapped(_ sender: Any) {
        delegate?.binkFloatingButtonsPrimaryButtonWasTapped(self)
    }
    
    @IBAction func secondaryButtonWasTapped(_ sender: Any) {
        delegate?.binkFloatingButtonsSecondaryButtonWasTapped(self)
    }
}
