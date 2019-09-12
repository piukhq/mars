//
//  MembershipCardBalanceModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardBalanceModel: Codable {
    let id: Int?
    let value: Double?
    let currency: String?
    let prefix: String?
    let suffix: String?
    let updatedAt: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case value
        case currency
        case prefix
        case suffix
        case updatedAt = "updated_at"
    }
}

extension MembershipCardBalanceModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCardBalance, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_MembershipCardBalance {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id ?? 0)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.value, with: NSNumber(value: value ?? 0), delta: delta)
        update(cdObject, \.currency, with: currency, delta: delta)
        update(cdObject, \.prefix, with: prefix, delta: delta)
        update(cdObject, \.suffix, with: suffix, delta: delta)
        update(cdObject, \.updatedAt, with: NSNumber(value: updatedAt ?? 0), delta: delta)

        return cdObject
    }
}
