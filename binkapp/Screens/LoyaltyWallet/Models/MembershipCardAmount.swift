//
//  MembershipCardAmount.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardAmount: Codable {
    let apiId: Int?
    let currency: String?
    let prefix: String?
    let suffix: String?
    let value: Double?
}

extension MembershipCardAmount: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCardAmount, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipCardAmount {
        update(cdObject, \.id, with: id(orOverrideId: overrideID), delta: delta)
        update(cdObject, \.currency, with: currency, delta: delta)
        update(cdObject, \.prefix, with: prefix, delta: delta)
        update(cdObject, \.suffix, with: suffix, delta: delta)
        update(cdObject, \.value, with: NSNumber(value: value ?? 0), delta: delta)

        return cdObject
    }
}
