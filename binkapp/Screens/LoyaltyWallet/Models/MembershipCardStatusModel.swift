//
//  MembershipCardStatusModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardStatusModel: Codable {
    let id: Int
    let state: String?
    let reasonCodes: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case state
        case reasonCodes = "reason_codes"
    }
}

extension MembershipCardStatusModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCardStatus, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_MembershipCardStatus {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.state, with: state, delta: delta)

        return cdObject
    }
}
