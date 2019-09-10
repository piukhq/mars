//
//  FullDetailsBrandHeader.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol FullDetailsBrandHeaderDelegate {
    func fullDetailsBrandHeaderDidTapShowBarcode(_ fullDetailsBrandHeader: FullDetailsBrandHeader)
}

class FullDetailsBrandHeader: CustomView {
    @IBOutlet private weak var brandImage: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    
    private var delegate: FullDetailsBrandHeaderDelegate?
    
    func configureWith(imageUrl: String?, delegate: FullDetailsBrandHeaderDelegate) {
        self.delegate = delegate
        if let imageURL = imageUrl, let url = URL(string: imageURL) {
            brandImage.af_setImage(withURL: url)
        }
        messageLabel.font = .bodyTextLarge
    }
    
    // MARK: - Actions

    @IBAction func showBarcodeTapped(_ sender: Any) {
        delegate?.fullDetailsBrandHeaderDidTapShowBarcode(self)
    }
}
