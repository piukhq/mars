//
//  VoucherModel.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct VoucherModel: Codable {
    var apiId: Int?
    var state: VoucherState?
    var code: String?
    var barcode: String?
    var barcodeType: String?
    var headline: String?
    var subtext: String?
    var dateRedeemed: Int?
    var dateIssued: Int?
    var expiryDate: Int?
    var earn: VoucherEarnModel?
    var burn: VoucherBurnModel?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case state
        case code
        case barcode
        case barcodeType = "barcode_type"
        case headline
        case subtext
        case dateRedeemed = "date_redeemed"
        case dateIssued = "date_issued"
        case expiryDate = "expiry_date"
        case earn
        case burn
    }
}

enum VoucherState: String, Codable {
    case redeemed
    case issued
    case inProgress = "inprogress"
    case expired
    case cancelled
}

extension VoucherModel: CoreDataMappable, CoreDataIDMappable {
    func objectToMapTo(_ cdObject: CD_Voucher, in context: NSManagedObjectContext, delta: Bool, overrideID: String?) -> CD_Voucher {
        update(cdObject, \.id, with: overrideID ?? id, delta: delta)
        update(cdObject, \.state, with: state?.rawValue, delta: delta)
        update(cdObject, \.code, with: code, delta: delta)
        update(cdObject, \.barcode, with: barcode, delta: delta)
        update(cdObject, \.barcodeType, with: barcodeType, delta: delta)
        update(cdObject, \.headline, with: headline, delta: delta)
        update(cdObject, \.subtext, with: subtext, delta: delta)
        update(cdObject, \.dateRedeemed, with: NSNumber(value: dateRedeemed ?? 0), delta: delta)
        update(cdObject, \.dateIssued, with: NSNumber(value: dateIssued ?? 0), delta: delta)
        update(cdObject, \.expiryDate, with: NSNumber(value: expiryDate ?? 0), delta: delta)

        if let earn = earn {
            let cdEarn = earn.mapToCoreData(context, .update, overrideID: VoucherEarnModel.overrideId(forParentId: id))
            update(cdEarn, \.voucher, with: cdObject, delta: delta)
            update(cdObject, \.earn, with: cdEarn, delta: delta)
        } else {
            update(cdObject, \.earn, with: nil, delta: false)
        }

        if let burn = burn {
            let cdBurn = burn.mapToCoreData(context, .update, overrideID: VoucherBurnModel.overrideId(forParentId: id))
            update(cdBurn, \.voucher, with: cdObject, delta: delta)
            update(cdObject, \.burn, with: cdBurn, delta: delta)
        } else {
            update(cdObject, \.burn, with: nil, delta: false)
        }

        return cdObject
    }
}
