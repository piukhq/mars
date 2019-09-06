//
//  AppsModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct AppsModel: Codable {
    let appId: String?
    let appStoreUrl: String?
    let appType: Int?

    enum CodingKeys: String, CodingKey {
        case appId = "app_id"
        case appStoreUrl = "app_store_url"
        case appType = "app_type"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        appId = try values.decodeIfPresent(String.self, forKey: .appId)
        appStoreUrl = try values.decodeIfPresent(String.self, forKey: .appStoreUrl)
        appType = try values.decodeIfPresent(Int.self, forKey: .appType)
    }
}
