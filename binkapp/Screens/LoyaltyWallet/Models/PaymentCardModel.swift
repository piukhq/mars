//
//  PaymentCardModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 10/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PaymentCardModel: Codable {
    var id: String
    var activeLink: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case activeLink = "active_link"
    }
}
