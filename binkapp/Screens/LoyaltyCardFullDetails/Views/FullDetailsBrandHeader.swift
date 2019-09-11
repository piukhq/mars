//
//  FullDetailsBrandHeader.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol FullDetailsBrandHeaderDelegate {
    func showBarcodeTapped()
}

class FullDetailsBrandHeader: CustomView {
    @IBOutlet private weak var brandImage: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    
    private var delegate: FullDetailsBrandHeaderDelegate?
    
    override func configureUI() {
        brandImage.image = UIImage(imageLiteralResourceName: "lcd_fallback")
        messageLabel.font = .bodyTextLarge
    }
    // MARK: - Actions

    @IBAction func showBarcodeTapped(_ sender: Any) {
        delegate?.showBarcodeTapped()
    }
}
