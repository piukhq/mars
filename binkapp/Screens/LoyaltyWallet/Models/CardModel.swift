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
    var barcode: String?
    var membershipId: String?
    var barcodeType: Int?
    let colour: String?
    let secondaryColour: String?
    let merchantName: String?
    
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case membershipId = "membership_id"
        case barcode
        case barcodeType = "barcode_type"
        case colour
        case secondaryColour = "secondary_colour"
        case merchantName
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
        update(cdObject, \.merchantName, with: merchantName, delta: delta)

        return cdObject
    }
}
