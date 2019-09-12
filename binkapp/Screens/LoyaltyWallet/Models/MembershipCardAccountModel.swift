//
//  MembershipCardAccountModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardAccountModel: Codable {
    let id: Int?
    let tier: Int?
}

extension MembershipCardAccountModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCardAccount, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_MembershipCardAccount {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id ?? 0)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.tier, with: NSNumber(value: tier ?? 0), delta: delta)

        return cdObject
    }
}
