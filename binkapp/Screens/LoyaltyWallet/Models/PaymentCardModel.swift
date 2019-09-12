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
    let id: Int?
    let activeLink: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case activeLink = "active_link"
    }
}

extension PaymentCardModel: CoreDataMappable {
    func objectToMapTo(_ cdObject: CD_PaymentCard, in context: NSManagedObjectContext, delta: Bool, overrideID: Int?) -> CD_PaymentCard {
        // Our codable models all need to have id's as Int's as dictated by API responses
        // However, we want to cast these all to strings so that our core data wrapper remains unchanged.
        let idString = String(id ?? 0)

        update(cdObject, \.id, with: idString, delta: delta)
        update(cdObject, \.activeLink, with: NSNumber(value: activeLink ?? false), delta: delta)

        return cdObject
    }
}
