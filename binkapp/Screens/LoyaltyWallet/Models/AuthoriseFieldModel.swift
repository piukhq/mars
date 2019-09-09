//
//  AuthoriseFieldModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct AuthoriseFieldModel: Codable {
    let id: Int
    let column: String?
    let validation: String?
    let description: String?
    let type: Int?
    let choice: [String]?
}
