//
//  MembershipCardModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 01/08/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipCardModel: Codable {
    let id: Int?
    let membership_plan: Int?
    let card: CardModel?
    let images: [MembershipCardImageModel]?
}
