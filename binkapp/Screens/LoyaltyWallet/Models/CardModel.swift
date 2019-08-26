//
//  CardModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct CardModel: Codable {
    let barcodeType: Int?
    let colour: String?
    
    enum CodingKeys: String, CodingKey {
        
        case barcodeType = "barcode_type"
        case colour = "colour"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        barcodeType = try values.decodeIfPresent(Int.self, forKey: .barcodeType)
        colour = try values.decodeIfPresent(String.self, forKey: .colour)
    }
}
