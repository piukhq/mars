//
//  WatchLoyaltyCard.swift
//  binkapp
//
//  Created by Sean Williams on 26/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

struct WatchLoyaltyCard: Codable {
    let id: String
    let companyName: String
    var iconImageData: Data?
    let barcodeImageData: Data
    let balanceString: String?
    
    var iconImage: UIImage? {
        if let iconImageData = iconImageData {
            return UIImage(data: iconImageData)
        }
        return nil
    }
    
    var barcodeImage: UIImage? {
        return UIImage(data: barcodeImageData)
    }
}

struct WatchLoyaltyCardIcon: Codable {
    let id: String
    let imageData: Data?
}
