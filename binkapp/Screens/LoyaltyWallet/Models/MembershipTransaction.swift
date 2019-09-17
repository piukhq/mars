//
//  MembershipTransaction.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipTransaction: Codable {
    let apiId: Int?
    let status: String?
    let timestamp: Int?
    let transactionDescription: String?
    let amounts: [MembershipCardAmount]?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case status = "status"
        case timestamp = "timestamp"
        case description = "description"
        case amounts = "amounts"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        timestamp = try values.decodeIfPresent(Double.self, forKey: .timestamp)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        amounts = try values.decodeIfPresent([MembershipCardAmount].self, forKey: .amounts)
    }
    
}
