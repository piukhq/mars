//
//  EnrolFieldModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct EnrolFieldModel: Codable {
    let id: String
    let column: String?
    let validation: String?
    let fieldDescription: String?
    let type: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case column
        case validation
        case fieldDescription = "description"
        case type
    }
}
