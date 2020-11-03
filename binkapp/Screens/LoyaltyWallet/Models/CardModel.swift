//
//  CardModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct CardModel: Codable, Hashable {
    let apiId: Int?
    let barcode: String?
    let membershipId: String?
    let barcodeType: Int?
    let colour: String?
    let secondaryColour: String?
    
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case membershipId = "membership_id"
        case barcode
        case barcodeType = "barcode_type"
        case colour
        case secondaryColour = "secondary_colour"
    }
}

extension CardModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_Card, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_Card {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.barcode, with: barcode, delta: delta)
        update(cdObject, \.barcodeType, with: NSNumber(value: barcodeType ?? 0), delta: delta)
        update(cdObject, \.colour, with: colour, delta: delta)
        update(cdObject, \.membershipId, with: membershipId, delta: delta)
        update(cdObject, \.secondaryColour, with: secondaryColour, delta: delta)

        return cdObject
    }
}
