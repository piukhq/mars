//
//  FieldChoice.swift
//  binkapp
//
//  Created by Nick Farrant on 16/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct FieldChoice: Codable {
    let apiId: Int?
    let value: String
}

extension FieldChoice: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_FieldChoice, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_FieldChoice {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.value, with: value, delta: delta)

        return cdObject
    }
}
