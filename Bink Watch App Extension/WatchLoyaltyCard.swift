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
    var barcodeImageData: Data?
    let balanceString: String?
    
    var iconImage: UIImage? {
        if let iconImageData = iconImageData {
            return UIImage(data: iconImageData)
        }
        return nil
    }
    
    var barcodeImage: UIImage? {
        if let barcodeImageData = barcodeImageData {
            return UIImage(data: barcodeImageData)
        }
        return nil
    }
}

struct WatchLoyaltyCardImageData: Codable {
    let id: String
    let iconImageData: Data?
    let barcodeImageData: Data?
}

enum WKSessionKey {
    static let refreshWallet = "refresh_wallet"
    static let hasCurrentUser = "has_current_user"
    static let addCard = "add_card"
    static let deleteCard = "delete_card"
    static let iconImage = "icon_image"
}
