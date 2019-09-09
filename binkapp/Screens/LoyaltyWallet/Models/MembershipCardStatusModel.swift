//
//  MembershipCardStatusModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardStatusModel: Codable {
    let id: Int
    let state: String?
    let reasonCodes: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case state
        case reasonCodes = "reason_codes"
    }
}
