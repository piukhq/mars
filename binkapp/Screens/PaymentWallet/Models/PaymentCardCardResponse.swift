//
//  PaymentCardCardResponse.swift
//  binkapp
//
//  Created by Nick Farrant on 29/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct PaymentCardCardResponse: Codable {
    var apiId: Int?
    var firstSix: String?
    var lastFour: String?
    var month: Int?
    var year: Int?
    var country: String?
    var currencyCode: String?
    var nameOnCard: String?
    var provider: PaymentCardType?
    var type: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case firstSix = "first_six_digits"
        case lastFour = "last_four_digits"
        case month
        case year
        case country
        case currencyCode = "currency_code"
        case nameOnCard = "name_on_card"
        case provider
        case type
    }
}

extension PaymentCardCardResponse: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_PaymentCardCard, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_PaymentCardCard {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.firstSix, with: firstSix, delta: delta)
        update(cdObject, \.lastFour, with: lastFour, delta: delta)
        update(cdObject, \.month, with: NSNumber(value: month ?? 0), delta: delta)
        update(cdObject, \.year, with: NSNumber(value: year ?? 0), delta: delta)
        update(cdObject, \.country, with: country, delta: delta)
        update(cdObject, \.currencyCode, with: currencyCode, delta: delta)
        update(cdObject, \.nameOnCard, with: nameOnCard, delta: delta)
        update(cdObject, \.provider, with: provider?.rawValue, delta: delta)
        update(cdObject, \.type, with: type, delta: delta)

        return cdObject
    }
}
