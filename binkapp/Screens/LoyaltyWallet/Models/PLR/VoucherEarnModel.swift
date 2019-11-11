//
//  VoucherEarnModel.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct VoucherEarnModel: Codable {
    var apiId: Int?
    var currency: String?
    var prefix: String?
    var suffix: String?
    var type: VoucherType?
    var targetValue: Double?
    var value: Double?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case currency
        case prefix
        case suffix
        case type
        case targetValue = "target_value"
        case value
    }
}
