//
//  PaymentCardMembershipCardResponse.swift
//  binkapp
//
//  Created by Nick Farrant on 29/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct LinkedCardResponse: Codable {
    var id: Int?
    var activeLink: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case activeLink = "active_link"
    }
}
