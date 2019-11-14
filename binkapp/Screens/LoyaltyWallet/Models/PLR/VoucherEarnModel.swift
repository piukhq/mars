//
//  VoucherEarnModel.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

enum VoucherEarnType: String, Codable {
    case accumulator
}

struct VoucherEarnModel: Codable {
    var apiId: Int?
    var currency: String?
    var prefix: String?
    var suffix: String?
    var type: VoucherEarnType?
    var targetValue: Double?
    var value: Double?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case currency
        case prefix
        case suffix
        case type
        case targetValue = "target_value"
        case value
    }
}

extension VoucherEarnModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_VoucherEarn, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_VoucherEarn {
        update(cdObject, \.id, with: id, delta: delta)
        update(cdObject, \.currency, with: currency, delta: delta)
        update(cdObject, \.prefix, with: prefix, delta: delta)
        update(cdObject, \.suffix, with: suffix, delta: delta)
        update(cdObject, \.type, with: type?.rawValue, delta: delta)
        update(cdObject, \.targetValue, with: NSNumber(value: targetValue ?? 0.0), delta: delta)
        update(cdObject, \.value, with: NSNumber(value: value ?? 0.0), delta: delta)

        return cdObject
    }
}
