//
//  PaymentCardModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 10/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PaymentCardModel: Codable {
    var id: Int?
    var activeLink: Bool?
    
    enum CodingKeys: String, CodingKey {
        
        case activeLink = "active_link"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        activeLink = try values.decodeIfPresent(Bool.self, forKey: .activeLink)
    }
}
