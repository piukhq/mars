//
//  LinkingSupportModel.swift
//  binkapp
//
//  Created by Nick Farrant on 17/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct LinkingSupportModel: Codable {
    let apiId: Int?
    let value: String
}

extension LinkingSupportModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_LinkingSupport, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_LinkingSupport {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.value, with: value, delta: delta)

        return cdObject
    }
}
