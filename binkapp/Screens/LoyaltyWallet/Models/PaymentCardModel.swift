//
//  PaymentCardModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 10/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct PaymentCardModel: Codable {
    let apiId: Int?
    let activeLink: Bool?
    
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case activeLink = "active_link"
    }
}

extension PaymentCardModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_PaymentCard, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_PaymentCard {
        update(cdObject, \.id, with: id(orOverrideId: overrideID), delta: delta)
        update(cdObject, \.activeLink, with: NSNumber(value: activeLink ?? false), delta: delta)

        return cdObject
    }
}
