//
//  PlanDynamicContentModel.swift
//  binkapp
//
//  Created by Nick Farrant on 25/02/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import CoreData

struct DynamicContentField: Codable {
    let apiId: Int?
    var column: String?
    var value: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case column
        case value
    }
}

extension DynamicContentField: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_PlanDynamicContent, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_PlanDynamicContent {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.column, with: column, delta: delta)
        update(cdObject, \.value, with: value, delta: delta)

        return cdObject
    }
}
