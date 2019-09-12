//
//  AddFieldModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct AddFieldModel: Codable {
    let id: Int?
    let column: String?
    let validation: String?
    let fieldDescription: String?
    let type: Int?
    let choice: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case column
        case validation
        case fieldDescription = "description"
        case type
        case choice
    }
}

extension AddFieldModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_AddField, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_AddField {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id ?? 0)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.column, with: column, delta: delta)
        update(cdObject, \.validation, with: validation, delta: delta)
        update(cdObject, \.fieldDescription, with: fieldDescription, delta: delta)
        update(cdObject, \.type, with: NSNumber(value: type ?? 0), delta: delta)

        return cdObject
    }
}
