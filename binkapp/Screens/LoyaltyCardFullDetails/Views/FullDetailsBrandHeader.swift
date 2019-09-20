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
        }
        //        brandImageBackgroundView.layer.shadowColor = UIColor.black.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        brandImageBackgroundView.clipsToBounds = true
        brandImage.clipsToBounds = true
        brandImageBackgroundView.layer.cornerRadius = 5
//        let shadowLayer = CAShapeLayer()
//        shadowLayer.path = UIBezierPath(roundedRect: brandImageBackgroundView.bounds, cornerRadius: 5).cgPath
//        shadowLayer.fillColor = UIColor.clear.cgColor
//
//        shadowLayer.shadowColor = UIColor.black.cgColor
//        shadowLayer.shadowPath = shadowLayer.path
//        shadowLayer.shadowOffset = .zero
//        shadowLayer.shadowOpacity = 0.1
//        shadowLayer.shadowRadius = 5
//
//        brandImageBackgroundView.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    // MARK: - Actions

    @IBAction func showBarcodeTapped(_ sender: Any) {
        delegate?.fullDetailsBrandHeaderDidTapShowBarcode(self)
    }
}
