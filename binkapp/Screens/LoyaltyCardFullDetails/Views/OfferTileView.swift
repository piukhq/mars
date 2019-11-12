//
//  OfferTileView.swift
//  binkapp
//
//  Created by Dorin Pop on 11/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class OfferTileView: CustomView {
    @IBOutlet private weak var offerImageView: UIImageView!
    
    func configure(imageUrl: String?) {
        offerImageView.clipsToBounds = true
        offerImageView.layer.cornerRadius = 8
        if let imageURL = imageUrl, let url = URL(string: imageURL) {
            offerImageView.af_setImage(withURL: url)
        }
    }
}

