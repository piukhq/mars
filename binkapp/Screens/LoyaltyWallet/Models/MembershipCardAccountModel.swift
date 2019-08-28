//
//  MembershipCardAccountModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipCardAccountModel : Codable {
    let tier : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case tier = "tier"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tier = try values.decodeIfPresent(Int.self, forKey: .tier)
    }
    
}
