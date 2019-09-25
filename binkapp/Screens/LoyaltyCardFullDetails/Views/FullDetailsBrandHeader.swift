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
    @IBOutlet private weak var showBarcodeTapGesture: UITapGestureRecognizer!
    
    private var delegate: FullDetailsBrandHeaderDelegate?
    
    func configure(imageUrl: String?, showBarcode: Bool,  delegate: FullDetailsBrandHeaderDelegate) {
        self.delegate = delegate
        messageLabel.isHidden = !showBarcode
        messageLabel.font = .bodyTextLarge
        showBarcodeTapGesture.isEnabled = showBarcode
        if let imageURL = imageUrl, let url = URL(string: imageURL) {
            brandImage.af_setImage(withURL: url)
            print(brandImage.image?.size)
        }
        brandImage.clipsToBounds = true
        brandImage.backgroundColor = .black
        brandImage.layer.cornerRadius = 4
    }
    
    // MARK: - Actions

    @IBAction func showBarcodeTapped(_ sender: Any) {
        delegate?.fullDetailsBrandHeaderDidTapShowBarcode(self)
    }
}
