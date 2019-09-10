//
//  TierModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct TierModel: Codable {
    let id: String
    let name: String?
    let tierDescription: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case tierDescription = "description"
    }
}

extension TierModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_Tier, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_Tier {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.name, with: name, delta: delta)
        update(cdObject, \.tierDescription, with: tierDescription, delta: delta)

        return cdObject
    }
}
