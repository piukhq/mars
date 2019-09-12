//
//  RegistrationFieldModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct RegistrationFieldModel: Codable {
    let id: Int?
    let column: String?
    let fieldDescription: String?
    let type: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case column
        case fieldDescription = "description"
        case type
    }
}

extension RegistrationFieldModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_RegistrationField, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_RegistrationField {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id ?? 0)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.column, with: column, delta: delta)
        update(cdObject, \.fieldDescription, with: fieldDescription, delta: delta)
        update(cdObject, \.type, with: NSNumber(value: type ?? 0), delta: delta)

        return cdObject
    }
}
