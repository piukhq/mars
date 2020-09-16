//
//  VoucherBurnModel.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

enum VoucherBurnType: String, Codable {
    case voucher
}

struct VoucherBurnModel: Codable {
    var apiId: Int?
    var currency: String?
    var prefix: String?
    var suffix: String?
    var value: Double?
    var type: VoucherBurnType?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case currency
        case prefix
        case suffix
        case value
        case type
    }
}

extension VoucherBurnModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_VoucherBurn, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_VoucherBurn {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.currency, with: currency, delta: delta)
        update(cdObject, \.prefix, with: prefix, delta: delta)
        update(cdObject, \.suffix, with: suffix, delta: delta)
        update(cdObject, \.type, with: type?.rawValue, delta: delta)
        
        // Value is optional, and we need it to be nil where there is no response from the API
        if let value = value {
            update(cdObject, \.value, with: NSNumber(value: value), delta: delta)
        } else {
            // Clear the value in case it used to have one, but doesn't now
            update(cdObject, \.value, with: nil, delta: delta)
        }

        return cdObject
    }
}
