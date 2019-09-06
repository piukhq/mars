//
//  BalanceModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct BalanceModel: Codable {
    let currency: String?
    let prefix: String?
    let suffix: String?
    let description: String?
}

