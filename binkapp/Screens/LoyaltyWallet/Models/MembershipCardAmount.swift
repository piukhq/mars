//
//  MembershipCardAmount.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipCardAmount: Codable {
    let currency: String?
    let suffix: String?
    let value: Double?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currency = try values.decodeIfPresent(String.self, forKey: .currency)
        suffix = try values.decodeIfPresent(String.self, forKey: .suffix)
        value = try values.decodeIfPresent(Double.self, forKey: .value)
    }
    
}
