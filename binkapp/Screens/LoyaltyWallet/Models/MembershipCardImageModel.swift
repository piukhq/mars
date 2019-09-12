//
//  MembershipCardImageModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardImageModel: Codable {
    let id: Int?
    let type: Int?
    let url: String?
    let imageDescription: String?
    let encoding: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case url
        case imageDescription = "description"
        case encoding
    }
}

extension MembershipCardImageModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCardImage, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_MembershipCardImage {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id ?? 0)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.type, with: NSNumber(value: type ?? 0), delta: delta)
        update(cdObject, \.url, with: url, delta: delta)
        update(cdObject, \.imageDescription, with: imageDescription, delta: delta)
        update(cdObject, \.encoding, with: encoding, delta: delta)

        return cdObject
    }
}
