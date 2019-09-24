//
//  CardModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct CardModel: Codable {
    let barcode: String?
    let membershipId: String?
    let barcodeType: Int?
    let colour: String?
    
    enum CodingKeys: String, CodingKey {
        case membershipId = "membership_id"
        case barcode = "barcode"
        case barcodeType = "barcode_type"
        case colour = "colour"
    }
}
