//
//  MembershipCardImageModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardImageModel: Codable {
    let apiId: Int?
    let type: Int?
    let url: String?
    let imageDescription: String?
    let encoding: String?
    
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case type
        case url
        case imageDescription = "description"
        case encoding
    }
}

extension MembershipCardImageModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipCardImage, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipCardImage {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.type, with: NSNumber(value: type ?? 0), delta: delta)
        update(cdObject, \.url, with: url, delta: delta)
        update(cdObject, \.imageDescription, with: imageDescription, delta: delta)
        update(cdObject, \.encoding, with: encoding, delta: delta)

        return cdObject
    }
}
