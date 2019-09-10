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
    @IBOutlet private weak var brandImageBackgroundView: UIView!
    
    private var delegate: FullDetailsBrandHeaderDelegate?
    
    func configureWith(imageUrl: String?, delegate: FullDetailsBrandHeaderDelegate) {
        self.delegate = delegate
        if let imageURL = imageUrl, let url = URL(string: imageURL) {
            brandImage.af_setImage(withURL: url)
        }
        messageLabel.font = .bodyTextLarge
        brandImageBackgroundView.layer.shadowColor = UIColor.black.cgColor
        brandImageBackgroundView.layer.shadowPath = UIBezierPath(roundedRect: brandImageBackgroundView.bounds, cornerRadius: 4).cgPath
    }
    
    // MARK: - Actions

    @IBAction func showBarcodeTapped(_ sender: Any) {
        delegate?.fullDetailsBrandHeaderDidTapShowBarcode(self)
    }
}
