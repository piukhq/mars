//
//  PLRCellViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 14/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PLRCellViewModel {
    private let voucher: CD_Voucher

    init(voucher: CD_Voucher) {
        self.voucher = voucher
    }

    var voucherState: VoucherState? {
        return VoucherState(rawValue: voucher.state ?? "")
    }

    var voucherAmountText: String? {
        return "\(voucher.burn?.prefix ?? "")\(voucher.burn?.value ?? 0.0)\(voucher.burn?.suffix ?? "") \(voucher.burn?.type ?? "")"
    }

    var voucherDescriptionText: String? {
        return "for spending \(voucher.earn?.prefix ?? "")\(voucher.earn?.targetValue ?? 0.0)"
    }

    var headlineText: String? {
        return voucher.headline
    }

    var amountAccumulated: Double {
        guard let target = voucher.earn?.targetValue?.doubleValue else { return 0 }
        guard let value = voucher.earn?.value?.doubleValue else { return 0 }
        // Cannot divide by 0, so return early
        guard target != 0 else {
            // This ensures that if target is 0 but value is also 0, then progress is 100%
            return value == 0 ? 1 : 0
        }
        return value/target
    }

    private var earnType: VoucherEarnType? {
        guard let earnType = voucher.earn?.type else { return nil }
        guard let type = VoucherEarnType(rawValue: earnType) else { return nil }
        return type
    }

    var earnProgressString: String? {
        guard let type = earnType else { return nil }
        switch type {
        case .accumulator:
            return "Spent"
        case .stamp:
            return "Collected"
        }
    }

    var earnProgressValueString: String? {
        guard let value = voucher.earn?.value?.floatValue else { return nil }
        return "\(voucher.earn?.prefix ?? "")\(String(format: "%.02f", value)) \(voucher.earn?.suffix ?? "")"
    }

    var earnTargetString: String? {
        guard let type = earnType else { return nil }
        switch type {
        case .accumulator:
            return "Goal"
        case .stamp:
            return ""
        }
    }

    var earnTargetValueString: String? {
        guard let value = voucher.earn?.targetValue?.floatValue else { return nil }
        return "\(voucher.earn?.prefix ?? "")\(String(format: "%.02f", value)) \(voucher.earn?.suffix ?? "")"
    }

    var dateText: String? {
        switch voucherState {
        case .expired:
            return String.fromTimestamp(voucher.expiryDate?.doubleValue, withFormat: .dayShortMonthYear, prefix: "on ")
        case .redeemed:
            return String.fromTimestamp(voucher.dateRedeemed?.doubleValue, withFormat: .dayShortMonthYear, prefix: "on ")
        default:
            return nil
        }
    }
}
