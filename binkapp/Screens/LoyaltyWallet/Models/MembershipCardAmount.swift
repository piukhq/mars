//
//  MembershipCardAmount.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardAmount: Codable {
    let id: Int
    let currency: String?
    let suffix: String?
    let value: Double?
}
