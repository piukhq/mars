//
//  PlanDocumentModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PlanDocumentModel: Codable {
    let id: String
    let name: String?
    let documentDescription: String?
    let url: String?
    let display: [String]?
    let checkbox: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case documentDescription = "description"
        case url
        case display
        case checkbox
    }
}
