//
//  EnrolFieldModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct EnrolFieldModel: Codable {
    let id: Int
    let column: String?
    let validation: String?
    let description: String?
    let type: Int?
}
