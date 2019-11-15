//
//  VoucherBurnModel.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct VoucherBurnModel: Codable {
    var apiId: Int?
    var currency: String?
    var prefix: String?
    var suffix: String?
    var value: Double?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case currency
        case prefix
        case suffix
        case value
    }
}

extension VoucherBurnModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_VoucherBurn, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_VoucherBurn {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.currency, with: currency, delta: delta)
        update(cdObject, \.prefix, with: prefix, delta: delta)
        update(cdObject, \.suffix, with: suffix, delta: delta)
        update(cdObject, \.value, with: NSNumber(value: value ?? 0.0), delta: delta)

        return cdObject
    }
}
