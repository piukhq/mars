//
//  TierModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct TierModel: Codable {
    let id: String
    let name: String?
    let tierDescription: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case tierDescription = "description"
    }
}
