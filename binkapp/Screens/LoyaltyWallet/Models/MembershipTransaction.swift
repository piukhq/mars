//
//  MembershipTransaction.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipTransaction: Codable {
    let apiId: Int?
    let status: String?
    let timestamp: Int?
    let transactionDescription: String?
    let amounts: [MembershipCardAmount]?
}

extension MembershipTransaction: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipTransaction, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipTransaction {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.status, with: status, delta: delta)
        update(cdObject, \.timestamp, with: NSNumber(value: timestamp ?? 0), delta: delta)

        return cdObject
    }
}
