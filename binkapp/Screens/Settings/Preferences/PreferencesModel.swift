//
//  PreferencesModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 21/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PreferencesModel: Codable {
    let isUserDefined: Bool?
    let user: Int?
    let value: String?
    let slug: String?
    let defaultValue: String?
    let valueType: String?
    let scheme: String?
    let label: String?
    let category: String?
    
    enum CodingKeys: String, CodingKey {
        case isUserDefined = "is_user_defined"
        case user
        case value
        case slug
        case defaultValue = "default_value"
        case valueType = "value_type"
        case scheme
        case label
        case category
    }
}
