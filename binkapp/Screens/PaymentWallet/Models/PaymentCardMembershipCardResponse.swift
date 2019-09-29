//
//  PaymentCardMembershipCardResponse.swift
//  binkapp
//
//  Created by Nick Farrant on 29/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct PaymentCardMembershipCardResponse: Codable {
    var apiId: Int?
    var activeLink: Bool

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case activeLink = "active_link"
    }
}

extension PaymentCardMembershipCardResponse: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_PaymentCardMembershipCard, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_PaymentCardMembershipCard {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.activeLink, with: NSNumber(value: activeLink), delta: delta)

        return cdObject
    }
}
