//
//  MembershipCardBalanceModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipCardBalanceModel: Codable {
   let value: Int?
   let currency: String?
   let prefix: String?
    let suffix: String?
   let updatedAt: Int?
    
    enum CodingKeys: String, CodingKey {
        
        case value = "value"
        case currency = "currency"
        case prefix = "prefix"
        case suffix = "suffix"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        value = try values.decodeIfPresent(Int.self, forKey: .value)
        currency = try values.decodeIfPresent(String.self, forKey: .currency)
        prefix = try values.decodeIfPresent(String.self, forKey: .prefix)
        suffix = try values.decodeIfPresent(String.self, forKey: .suffix)
        updatedAt = try values.decodeIfPresent(Int.self, forKey: .updatedAt)
    }
}
