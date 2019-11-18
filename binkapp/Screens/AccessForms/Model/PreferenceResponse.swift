//
//  EmptyResponse.swift
//  binkapp
//
//  Created by Max Woodhams on 06/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PreferenceResponse: Codable {
    let slug: String
    let isUserDefined: Bool
    let user: Int
    let value: String
    let defaultValue: String
    let valueType: String
    let scheme: Int
    let label: String
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case slug
        case isUserDefined = "is_user_defined"
        case user
        case value
        case defaultValue = "default_value"
        case valueType = "value_type"
        case scheme
        case label
        case category
    }
}
