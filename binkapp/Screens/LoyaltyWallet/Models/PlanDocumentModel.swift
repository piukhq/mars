//
//  PlanDocumentModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct PlanDocumentModel: Codable {
    let apiId: Int?
    let name: String?
    let documentDescription: String?
    let url: String?
    let display: [PlanDocumentDisplayModel]?
    let checkbox: Bool?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case name
        case documentDescription = "description"
        case url
        case display
        case checkbox
    }
}

extension PlanDocumentModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_PlanDocument, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_PlanDocument {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.name, with: name, delta: delta)
        update(cdObject, \.documentDescription, with: documentDescription, delta: delta)
        update(cdObject, \.url, with: url, delta: delta)
        update(cdObject, \.checkbox, with: NSNumber(value: checkbox ?? false), delta: delta)

        if let display = display {
            for (index, display) in display.enumerated() {
                let indexID = PlanDocumentDisplayModel.overrideId(forParentId: overrideID ?? id) + String(index)
                let cdDisplay = display.mapToCoreData(context, .update, overrideID: indexID)
                update(cdDisplay, \.planDocument, with: cdObject, delta: delta)
                cdObject.addDisplayObject(cdDisplay)
            }
        }

        return cdObject
    }
}
