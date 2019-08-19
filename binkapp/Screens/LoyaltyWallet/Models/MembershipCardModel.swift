//
//  MembershipCardModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipCardModel: Codable {
    let id: Int?
    let membershipPlan: Int?
    let card: CardModel?
    let images: [MembershipCardImageModel]?
}
