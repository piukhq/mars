//
//  BalanceModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct BalanceModel: Codable {
    let apiId: Int?
    let currency: String?
    let prefix: String?
    let suffix: String?
    let balanceDescription: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case currency
        case prefix
        case suffix
        case balanceDescription = "description"
    }
}

extension BalanceModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_Balance, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_Balance {
        update(cdObject, \.id, with: id(orOverrideId: overrideID), delta: delta)
        update(cdObject, \.currency, with: currency, delta: delta)
        update(cdObject, \.prefix, with: prefix, delta: delta)
        update(cdObject, \.suffix, with: suffix, delta: delta)
        update(cdObject, \.balanceDescription, with: balanceDescription, delta: delta)

        return cdObject
    }
}
