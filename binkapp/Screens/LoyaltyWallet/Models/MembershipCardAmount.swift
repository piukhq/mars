//
//  MembershipCardAmount.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct MembershipCardAmount: Codable {
    let id: String
    let currency: String?
    let suffix: String?
    let value: Double?
}
