//
//  BalanceModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct BalanceModel: Codable {
    let id: String
    let currency: String?
    let prefix: String?
    let suffix: String?
    let balanceDescription: String?

    enum CodingKeys: String, CodingKey {
        case id
        case currency
        case prefix
        case suffix
        case balanceDescription = "description"
    }
}

