//
//  RegistrationFieldModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct RegistrationFieldModel: Codable {
    let id: String
    let column: String?
    let fieldDescription: String?
    let type: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case column
        case fieldDescription = "description"
        case type
    }
}
