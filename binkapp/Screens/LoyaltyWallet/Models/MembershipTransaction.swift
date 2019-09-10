//
//  MembershipTransaction.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipTransaction: Codable {
    let id: String
    let status: String?
    let timestamp: Int?
    let transactionDescription: String?
    let amounts: [MembershipCardAmount]?
}
