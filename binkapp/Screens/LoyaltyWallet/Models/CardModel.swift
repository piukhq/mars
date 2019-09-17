//
//  CardModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct CardModel: Codable {
    let id: String
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

extension CardModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_Card, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_Card {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.barcode, with: barcode, delta: delta)
        update(cdObject, \.barcodeType, with: NSNumber(value: barcodeType ?? 0), delta: delta)
        update(cdObject, \.colour, with: colour, delta: delta)

        return cdObject
    }
}
