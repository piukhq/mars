//
//  MembershipCardStatusModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipCardStatusModel: Codable {
    
    enum CardState: String, Codable {
        case failed
        case pending
        case authorised
        case unauthorised
        case unknown
    }
    
    let state : CardState?
    let reasonCodes : [String]?
    
    enum CodingKeys: String, CodingKey {
        case state = "state"
        case reasonCodes = "reason_codes"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        state = try values.decodeIfPresent(CardState.self, forKey: .state)
        reasonCodes = try values.decodeIfPresent([String].self, forKey: .reasonCodes)
    }
}

extension MembershipCardStatusModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(state)
        hasher.combine(reasonCodes)
    }
}
