//
//  CardModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct CardModel: Codable {
    let id: Int
    let barcode: String?
    let barcodeType: Int?
    let colour: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case barcode
        case barcodeType = "barcode_type"
        case colour
    }
}
