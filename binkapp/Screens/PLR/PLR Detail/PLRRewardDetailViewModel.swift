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
        switch voucherState {
        case .issued:
            return "Your \(voucherAmountText) is ready!"
        case .redeemed:
            return "Your \(voucherAmountText) was redeemed"
        case .expired:
            return "Your \(voucherAmountText) has expired"
        default:
            return nil
        }
    }

    var subtextString: String? {
        return voucher.subtext
    }

    var issuedDateString: String? {
        guard let timestamp = voucher.dateIssued else { return nil }
        let date = Date(timeIntervalSince1970: timestamp.doubleValue)
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.PLR.voucherDetail.rawValue
        return "Added \(formatter.string(from: date))"
    }

    var redeemedDateString: String? {
        guard let timestamp = voucher.dateRedeemed else { return nil }
        let date = Date(timeIntervalSince1970: timestamp.doubleValue)
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.PLR.voucherDetail.rawValue
        return "Redeemed \(formatter.string(from: date))"
    }

    var expiredDateString: String? {
        guard let timestamp = voucher.expiryDate else { return nil }
        let date = Date(timeIntervalSince1970: timestamp.doubleValue)
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.PLR.voucherDetail.rawValue
        return "Expired \(formatter.string(from: date))"
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

    var voucherAmountText: String {
        return "\(voucher.burn?.prefix ?? "")\(voucher.burn?.value ?? 0.0)\(voucher.burn?.suffix ?? "") \(voucher.burn?.type ?? "")"
    }
}
