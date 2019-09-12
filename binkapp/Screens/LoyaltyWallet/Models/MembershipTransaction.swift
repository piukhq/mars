//
//  MembershipTransaction.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipTransaction: Codable {
    let id: Int?
    let status: String?
    let timestamp: Int?
    let description : String?
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
        timestamp = try values.decodeIfPresent(Int.self, forKey: .timestamp)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        amounts = try values.decodeIfPresent([MembershipCardAmount].self, forKey: .amounts)
    }
}

extension MembershipTransaction: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(status)
        hasher.combine(timestamp)
        hasher.combine(description)
        hasher.combine(amounts)
    }
}
