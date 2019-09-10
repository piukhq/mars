//
//  MembershipCardBalanceModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardBalanceModel: Codable {
    let id: String
    let value: Double?
    let currency: String?
    let prefix: String?
    let suffix: String?
    let updatedAt: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case value
        case currency
        case prefix
        case suffix
        case updatedAt = "updated_at"
    }
}
