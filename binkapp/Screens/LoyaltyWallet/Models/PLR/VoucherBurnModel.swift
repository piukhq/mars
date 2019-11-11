//
//  VoucherBurnModel.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct VoucherBurnModel: Codable {
    var apiId: Int?
    var currency: String?
    var prefix: String?
    var suffix: String?
    var value: Double?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case currency
        case prefix
        case suffix
        case value
    }
}
