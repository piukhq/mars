//
//  PLRRewardDetailViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 13/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PLRRewardDetailViewModel {
    private let voucher: CD_Voucher

    init(voucher: CD_Voucher) {
        self.voucher = voucher
    }

    var voucherCellViewModel: PLRCellViewModel {
        return PLRCellViewModel(voucher: voucher)
    }

    // MARK: - String values

    var codeString: String? {
        return voucher.code
    }

    var headerString: String? {
        return voucher.headline
    }

    var subtextString: String? {
        return voucher.subtext
    }

    var issuedDateString: String? {
        guard let timestamp = voucher.dateIssued else { return nil }
        let date = Date(timeIntervalSince1970: timestamp.doubleValue)
        return date.timeIntervalSince1970.stringFromTimeInterval()
    }

    var redeemedDateString: String? {
        guard let timestamp = voucher.dateRedeemed else { return nil }
        let date = Date(timeIntervalSince1970: timestamp.doubleValue)
        return date.timeIntervalSince1970.stringFromTimeInterval()
    }

    var expiredDateString: String? {
        guard let timestamp = voucher.expiryDate else { return nil }
        let date = Date(timeIntervalSince1970: timestamp.doubleValue)
        return date.timeIntervalSince1970.stringFromTimeInterval()
    }

    // MARK: - View decisioning

    var shouldShowCode: Bool {
        return voucherState != .inProgress
    }

    var shouldShowHeader: Bool {
        return voucherState != .inProgress
    }

    var shouldShowSubtext: Bool {
        return false
    }

    var shouldShowIssuedDate: Bool {
        return voucherState == .issued || voucherState == .redeemed
    }

    var shouldShowRedeemedDate: Bool {
        return voucherState == .redeemed
    }

    var shouldShowExpiredDate: Bool {
        return voucherState == .expired
    }

    // MARK: - Private helpers

    var voucherState: VoucherState? {
        return VoucherState(rawValue: voucher.state ?? "")
    }
}
