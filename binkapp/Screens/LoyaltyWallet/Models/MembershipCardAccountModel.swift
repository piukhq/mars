//
//  MembershipCardAccountModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardAccountModel: Codable {
    let apiId: Int?
    let tier: Int?
}

extension MembershipCardAccountModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCardAccount, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipCardAccount {
        update(cdObject, \.id, with: id(orOverrideId: overrideID), delta: delta)
        update(cdObject, \.tier, with: NSNumber(value: tier ?? 0), delta: delta)

        return cdObject
    }
}
