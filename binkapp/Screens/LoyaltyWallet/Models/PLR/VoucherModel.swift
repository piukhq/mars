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
    var barcodeType: Int?
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
