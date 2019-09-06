//
//  MembershipCardAmount.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardAmount: Codable {
    let id: String
    let currency: String?
    let suffix: String?
    let value: Double?
}

extension MembershipCardAmount: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCardAmount, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipCardAmount {
        update(cdObject, \.currency, with: currency, delta: delta)
        update(cdObject, \.suffix, with: suffix, delta: delta)
        update(cdObject, \.value, with: NSNumber(value: value ?? 0), delta: delta)

        return cdObject
    }
}
