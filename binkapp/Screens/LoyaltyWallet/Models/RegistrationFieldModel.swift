//
//  RegistrationFieldModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct RegistrationFieldModel: Codable {
    let id: Int
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
    func objectToMapTo(_ cdObject: CD_RegistrationField, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_RegistrationField {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.column, with: column, delta: delta)
        update(cdObject, \.fieldDescription, with: fieldDescription, delta: delta)
        update(cdObject, \.type, with: NSNumber(value: type ?? 0), delta: delta)

        return cdObject
    }
}
