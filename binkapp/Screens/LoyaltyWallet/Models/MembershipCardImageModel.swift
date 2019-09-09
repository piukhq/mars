//
//  MembershipCardImageModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipCardImageModel: Codable {
    let id: Int
    let type: Int?
    let url: String?
    let imageDescription: String?
    let encoding: String?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case url
        case imageDescription = "description"
        case encoding
    }
}
