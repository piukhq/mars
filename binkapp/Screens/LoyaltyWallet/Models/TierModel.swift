//
//  TierModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct TierModel: Codable {
    let id: Int
    let name: String?
    let tierDescription: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case tierDescription = "description"
    }
}

extension TierModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_Tier, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_Tier {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.name, with: name, delta: delta)
        update(cdObject, \.tierDescription, with: tierDescription, delta: delta)

        return cdObject
    }
}
