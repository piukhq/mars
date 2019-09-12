//
//  CardModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

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

extension CardModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_Card, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_Card {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.barcode, with: barcode, delta: delta)
        update(cdObject, \.barcodeType, with: NSNumber(value: barcodeType ?? 0), delta: delta)
        update(cdObject, \.colour, with: colour, delta: delta)

        return cdObject
    }
}
