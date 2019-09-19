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

    var apiId: Int? {
        return nil // This will force CoreDataIDMappable to kick in and give this object a computed id based on the parent object
    }
}

extension LinkingSupportType: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_LinkingSupport, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_LinkingSupport {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.value, with: rawValue, delta: delta)

        return cdObject
    }
}
