//
//  APIErrorResponses.swift
//  binkapp
//
//  Created by Nick Farrant on 16/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct ResponseErrors: Decodable {
    let nonFieldErrors: [String]?

    enum CodingKeys: String, CodingKey {
        case nonFieldErrors = "non_field_errors"
    }
}
