//
//  AddFieldModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct AddFieldModel: Codable {
    let apiId: Int?
    let column: String?
    let validation: String?
    let fieldDescription: String?
    let type: Int?
    let choices: [FieldChoice]?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case column
        case validation
        case fieldDescription = "description"
        case type
        case choices = "choice"
    }
}

extension AddFieldModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_AddField, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_AddField {
        update(cdObject, \.id, with: id(orOverrideId: overrideID), delta: delta)
        update(cdObject, \.column, with: column, delta: delta)
        update(cdObject, \.validation, with: validation, delta: delta)
        update(cdObject, \.fieldDescription, with: fieldDescription, delta: delta)
        update(cdObject, \.type, with: NSNumber(value: type ?? 0), delta: delta)

        cdObject.choices.forEach {
            guard let choice = $0 as? CD_FieldChoice else { return }
            context.delete(choice)
        }
        choices?.forEach { choice in
            let overrideId = FieldChoice.overrideId(forParentId: id(orOverrideId: overrideID), withExtension: choice.id)
            let cdChoice = choice.mapToCoreData(context, .update, overrideID: overrideId)
            update(cdChoice, \.addField, with: cdObject, delta: delta)
            cdObject.addChoicesObject(cdChoice)
        }

        return cdObject
    }
}
