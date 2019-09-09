//
//  RegistrationFieldModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct RegistrationFieldModel: Codable {
    let id: Int
    let column: String?
    let description: String?
    let type: Int?
}
