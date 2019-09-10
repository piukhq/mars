//
//  MembershipCardBalanceModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardBalanceModel: Codable {
    let id: String
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
    func objectToMapTo(_ cdObject: CD_MembershipCardBalance, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipCardBalance {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.value, with: NSNumber(value: value ?? 0), delta: delta)
        update(cdObject, \.currency, with: currency, delta: delta)
        update(cdObject, \.prefix, with: prefix, delta: delta)
        update(cdObject, \.suffix, with: suffix, delta: delta)
        update(cdObject, \.updatedAt, with: NSNumber(value: updatedAt ?? 0), delta: delta)

        return cdObject
    }
}
