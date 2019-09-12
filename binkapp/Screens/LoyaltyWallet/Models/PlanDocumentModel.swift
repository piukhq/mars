//
//  PlanDocumentModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct PlanDocumentModel: Codable {
    let id: Int
    let name: String?
    let documentDescription: String?
    let url: String?
    let display: [String]?
    let checkbox: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case documentDescription = "description"
        case url
        case display
        case checkbox
    }
}

extension PlanDocumentModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_PlanDocument, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_PlanDocument {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.name, with: name, delta: delta)
        update(cdObject, \.documentDescription, with: documentDescription, delta: delta)
        update(cdObject, \.url, with: url, delta: delta)
        update(cdObject, \.checkbox, with: NSNumber(value: checkbox ?? false), delta: delta)

        return cdObject
    }
}
