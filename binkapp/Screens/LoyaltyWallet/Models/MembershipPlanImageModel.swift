//
//  MembershipPlanImageModel.swift
//  binkapp
//
//  Created by Max Woodhams on 25/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipPlanImageModel: Codable, Hashable {
    let apiId: Int?
    let type: Int?
    let url: String?
    let imageDescription: String?
    let encoding: String?
    let ctaUrl: String?
    let darkModeUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case type
        case url
        case imageDescription = "description"
        case encoding
        case ctaUrl = "cta_url"
        case darkModeUrl = "dark_mode_url"
    }
}

extension MembershipPlanImageModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_MembershipPlanImage, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_MembershipPlanImage {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.type, with: NSNumber(value: type ?? 0), delta: delta)
        update(cdObject, \.imageUrl, with: url, delta: delta)
        update(cdObject, \.imageDescription, with: imageDescription, delta: delta)
        update(cdObject, \.encoding, with: encoding, delta: delta)
        update(cdObject, \.ctaUrl, with: ctaUrl, delta: delta)
        update(cdObject, \.darkModeImageUrl, with: darkModeUrl, delta: delta)

        return cdObject
    }
}
