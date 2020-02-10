//
//  EnrolFieldModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct EnrolFieldModel: Codable {
    let apiId: Int?
    let column: String?
    let validation: String?
    let fieldDescription: String?
    let type: Int?
    let choices: [FieldChoice]?
    let commonName: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case column
        case validation
        case fieldDescription = "description"
        case type
        case choices = "choice"
        case commonName = "common_name"
    }
}

extension EnrolFieldModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_EnrolField, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_EnrolField {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.column, with: column, delta: delta)
        update(cdObject, \.validation, with: validation, delta: delta)
        update(cdObject, \.fieldDescription, with: fieldDescription, delta: delta)
        update(cdObject, \.type, with: NSNumber(value: type ?? 0), delta: delta)
        update(cdObject, \.commonName, with: commonName, delta: delta)
        
        cdObject.choices.forEach {
            guard let choice = $0 as? CD_FieldChoice else { return }
            context.delete(choice)
        }
        
        if let choices = choices {
            for (index, choice) in choices.enumerated() {
                let indexID = EnrolFieldModel.overrideId(forParentId: overrideID ?? id) + String(index)
                let cdChoice = choice.mapToCoreData(context, .update, overrideID: indexID)
                update(cdChoice, \.enrolField, with: cdObject, delta: delta)
                cdObject.addChoicesObject(cdChoice)
            }
        }

        return cdObject
    }
}
