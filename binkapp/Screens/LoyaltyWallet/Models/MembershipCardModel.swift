//
//  MembershipCardModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 01/08/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct MembershipCardModel: Codable {
    let barcode: String
    let barcode_type: Int
    let membership_id: String
    let colour: String
    let images: MembershipCardImageModel
}
