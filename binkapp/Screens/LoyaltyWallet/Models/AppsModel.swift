//
//  AppsModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

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
