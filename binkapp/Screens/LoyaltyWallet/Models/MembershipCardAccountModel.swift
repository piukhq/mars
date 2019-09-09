//
//  MembershipCardAccountModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardAccountModel: Codable {
    let id: String
    let tier: Int?
}

extension MembershipCardAccountModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCardAccount, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipCardAccount {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.tier, with: NSNumber(value: tier ?? 0), delta: delta)

        return cdObject
    }
}
