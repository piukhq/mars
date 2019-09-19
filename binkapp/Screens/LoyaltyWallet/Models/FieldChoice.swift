//
//  FieldChoice.swift
//  binkapp
//
//  Created by Nick Farrant on 16/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

typealias FieldChoice = String

extension FieldChoice {
    public var apiId: Int? {
        return nil
    }
}

extension FieldChoice: CoreDataMappable, CoreDataIDMappable {
    public func objectToMapTo(_ cdObject: CD_FieldChoice, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_FieldChoice {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.value, with: self, delta: delta)

        return cdObject
    }
}
