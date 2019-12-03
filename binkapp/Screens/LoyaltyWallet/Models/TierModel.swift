//
//  TierModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct TierModel: Codable {
    let apiId: Int?
    let name: String?
    let tierDescription: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case name
        case tierDescription = "description"
    }
}

extension TierModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_Tier, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_Tier {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.name, with: name, delta: delta)
        update(cdObject, \.tierDescription, with: tierDescription, delta: delta)

        return cdObject
    }
}
