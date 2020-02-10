//
//  MembershipCardPostModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipCardPostModel: Codable {
    var account: AccountPostModel?
    var membershipPlan: Int?
    
    enum CodingKeys: String, CodingKey {
        case account = "account"
        case membershipPlan = "membership_plan"
    }
}
