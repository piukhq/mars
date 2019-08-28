//
//  MembershipCardAmount.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipCardAmount : Codable {
    let currency : String?
    let suffix : String?
    let value : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case currency = "currency"
        case suffix = "suffix"
        case value = "value"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currency = try values.decodeIfPresent(String.self, forKey: .currency)
        suffix = try values.decodeIfPresent(String.self, forKey: .suffix)
        value = try values.decodeIfPresent(Int.self, forKey: .value)
    }
    
}
