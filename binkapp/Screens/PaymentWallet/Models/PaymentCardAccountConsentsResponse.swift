//
//  PaymentCardAccountConsentsResponse.swift
//  binkapp
//
//  Created by Nick Farrant on 29/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct PaymentCardAccountConsentsResponse: Codable {
    var apiId: Int?
    var type: Int?
    var timestamp: Int?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case type
        case timestamp
    }
}

extension PaymentCardAccountConsentsResponse: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_PaymentCardAccountConsents, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_PaymentCardAccountConsents {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.type, with: NSNumber(value: type ?? 0), delta: delta)
        update(cdObject, \.timestamp, with: NSNumber(value: timestamp ?? 0), delta: delta)

        return cdObject
    }
}
