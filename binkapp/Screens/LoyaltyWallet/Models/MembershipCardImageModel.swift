//
//  MembershipCardImageModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipCardImageModel: Codable, Hashable {
    let id: Int?
    let type: Int?
    let url: String?
    let description: String?
    let encoding: String?
}
