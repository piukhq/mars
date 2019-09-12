//
//  BalanceModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct BalanceModel: Codable {
    let id: Int
    let currency: String?
    let prefix: String?
    let suffix: String?
    let balanceDescription: String?

    enum CodingKeys: String, CodingKey {
        case id
        case currency
        case prefix
        case suffix
        case balanceDescription = "description"
    }
}

extension BalanceModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_Balance, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_Balance {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.currency, with: currency, delta: delta)
        update(cdObject, \.prefix, with: prefix, delta: delta)
        update(cdObject, \.suffix, with: suffix, delta: delta)
        update(cdObject, \.balanceDescription, with: balanceDescription, delta: delta)

        return cdObject
    }
}
