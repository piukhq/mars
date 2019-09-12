//
//  MembershipCardAmount.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardAmount: Codable {
    let id: Int?
    let currency: String?
    let suffix: String?
    let value: Double?
}

extension MembershipCardAmount: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCardAmount, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_MembershipCardAmount {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id ?? 0)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.currency, with: currency, delta: delta)
        update(cdObject, \.suffix, with: suffix, delta: delta)
        update(cdObject, \.value, with: NSNumber(value: value ?? 0), delta: delta)

        return cdObject
    }
}
