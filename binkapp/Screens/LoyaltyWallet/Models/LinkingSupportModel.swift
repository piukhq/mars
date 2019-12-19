//
//  LinkingSupportModel.swift
//  binkapp
//
//  Created by Nick Farrant on 17/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

enum LinkingSupportType: String, Codable {
    case add = "ADD"
    case registration = "REGISTRATION"
    case enrol = "ENROL"
    case unknown

    var apiId: Int? {
        return nil // This will force CoreDataIDMappable to kick in and give this object a computed id based on the parent object
    }
    
    /// Support that sometimes Plan Document Display could refer to non Bink native applications
    public init(from decoder: Decoder) throws {
        self = try LinkingSupportType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

extension LinkingSupportType: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_LinkingSupport, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_LinkingSupport {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.value, with: rawValue, delta: delta)

        return cdObject
    }
}
