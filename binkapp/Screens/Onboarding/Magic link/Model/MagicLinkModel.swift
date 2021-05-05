//
//  MagicLinkModel.swift
//  binkapp
//
//  Created by Nick Farrant on 04/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

struct MagicLinkRequestModel: Codable {
    let email: String
    let slug: String
    let locale: String
    let bundleId: String
    
    init(email: String) {
        self.email = email
        self.slug = "iceland-bonus-card-mock"
        self.locale = "en_GB"
        self.bundleId = APIConstants.bundleID
    }
    
    enum CodingKeys: String, CodingKey {
        case email
        case slug
        case locale
        case bundleId = "bundle_id"
    }
}

struct MagicLinkAccessTokenRequestModel: Codable {
    let token: String
}
