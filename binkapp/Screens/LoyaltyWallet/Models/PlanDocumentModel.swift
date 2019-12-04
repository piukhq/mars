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
    let display: [String]?
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

        return cdObject
    }
}
