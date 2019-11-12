//
//  FullDetailsBrandHeader.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol FullDetailsBrandHeaderDelegate: NSObject {
    func fullDetailsBrandHeaderDidTapShowBarcode(_ fullDetailsBrandHeader: FullDetailsBrandHeader)
}

class FullDetailsBrandHeader: CustomView {
    @IBOutlet private weak var brandImageView: UIImageView!
    @IBOutlet private weak var showBarcodeButton: UIButton!

    private weak var delegate: FullDetailsBrandHeaderDelegate?
    
    func configure(imageUrl: String?, showBarcode: Bool,  delegate: FullDetailsBrandHeaderDelegate) {
        self.delegate = delegate
        let buttonTitle = showBarcode ? "details_header_show_barcode".localized : "details_header_show_card_number".localized
        showBarcodeButton.setTitle(buttonTitle, for: .normal)
        if let imageURL = imageUrl, let url = URL(string: imageURL) {
            brandImageView.af_setImage(withURL: url)
        }
        brandImageView.layer.cornerRadius = 8
    }
    
    // MARK: - Actions

    @IBAction func showBarcodeButtonTapped(_ sender: Any) {
        delegate?.fullDetailsBrandHeaderDidTapShowBarcode(self)
    }
}
