//
//  MembershipCardStatusModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipCardStatusModel: Codable {
    let state : String?
    let reasonCodes : [String]?
    
    enum MembershipCardStatus: String {
        case authorised
        case unauthorised
        case pending
        case failed 
    }
    
    enum CodingKeys: String, CodingKey {
        
        case state = "state"
        case reasonCodes = "reason_codes"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        state = try values.decodeIfPresent(String.self, forKey: .state)
        reasonCodes = try values.decodeIfPresent([String].self, forKey: .reasonCodes)
    }
    
}
