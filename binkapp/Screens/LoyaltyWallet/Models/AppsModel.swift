//
//  AppsModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct AppsModel: Codable {
    let id: Int
    let appId: String?
    let appStoreUrl: String?
    let appType: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case appId = "app_id"
        case appStoreUrl = "app_store_url"
        case appType = "app_type"
    }
}

extension AppsModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_App, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_App {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.appId, with: appId, delta: delta)
        update(cdObject, \.appStoreUrl, with: appStoreUrl, delta: delta)
        update(cdObject, \.appType, with: NSNumber(value: appType ?? 0), delta: delta)

        return cdObject
    }
}
