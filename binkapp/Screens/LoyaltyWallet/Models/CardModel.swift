//
//  CardModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct CardModel: Codable {
    let barcode: String?
    let barcodeType: Int?
    let colour: String?
    
    enum CodingKeys: String, CodingKey {
        
        case barcode = "barcode"
        case barcodeType = "barcode_type"
        case colour = "colour"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        barcode = try values.decodeIfPresent(String.self, forKey: .barcode)
        barcodeType = try values.decodeIfPresent(Int.self, forKey: .barcodeType)
        colour = try values.decodeIfPresent(String.self, forKey: .colour)
    }
}
