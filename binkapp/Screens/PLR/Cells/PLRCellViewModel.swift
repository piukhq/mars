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
        return voucher.voucherState
    }

    var voucherAmountText: String? {
        switch voucherEarnType {
        case .accumulator:
            return "\(voucher.burn?.prefix ?? "")\(voucher.burn?.value?.twoDecimalPointString() ?? "")\(voucher.burn?.suffix ?? "") \(voucher.burn?.type ?? "")"
        case .stamps:
            var valueString = ""
            if let burnValueString = voucher.burn?.value?.twoDecimalPointString() {
                valueString = burnValueString
            }
            return "\(voucher.burn?.prefix ?? "")\(valueString) \(voucher.burn?.suffix ?? "")"
        default:
            return ""
        }
    }

    var voucherDescriptionText: String? {
        switch voucherEarnType {
        case .accumulator:
            return L10n.plrVoucherAccumulatorBurnDescription(voucher.earn?.prefix ?? "", voucher.earn?.targetValue?.twoDecimalPointString() ?? "")
        case .stamps:
            return L10n.plrVoucherStampBurnDescription(voucher.earn?.prefix ?? "", voucher.earn?.targetValue?.twoDecimalPointString() ?? "", voucher.earn?.suffix ?? "")
        default:
            return ""
        }
    }

    var voucherEarnType: VoucherEarnType? {
        return VoucherEarnType(rawValue: voucher.earn?.type ?? "")
    }

    var headlineText: String? {
        return voucher.formattedHeadline
    }

    var amountAccumulated: Double {
        guard let target = voucher.earn?.targetValue?.doubleValue else { return 0 }
        guard let value = voucher.earn?.value?.doubleValue else { return 0 }
        // Cannot divide by 0, so return early
        guard target != 0 else {
            // This ensures that if target is 0 but value is also 0, then progress is 100%
            return value == 0 ? 1 : 0
        }
        return value / target
    }

    var stampsCollected: Int {
        return voucher.earn?.value?.intValue ?? 0
    }

    var stampsAvailable: Int {
        return voucher.earn?.targetValue?.intValue ?? 0
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
            return L10n.plrVoucherAccumulatorEarnValueTitle
        case .stamps:
            return L10n.plrVoucherStampEarnValueTitle
        }
    }

    var earnProgressValueString: String? {
        switch voucherEarnType {
        case .accumulator:
            guard let value = voucher.earn?.value?.floatValue else { return nil }
            return "\(voucher.earn?.prefix ?? "")\(String(format: "%.02f", value)) \(voucher.earn?.suffix ?? "")"
        case .stamps:
            let earnValue = voucher.earn?.value?.intValue
            let earnTargetValue = voucher.earn?.targetValue?.intValue
            let earnSuffix = voucher.earn?.suffix
            return "\(earnValue ?? 0)/\(earnTargetValue ?? 0) \(earnSuffix ?? "")"
        default:
            return nil
        }
    }

    var earnTargetString: String? {
        guard let type = earnType else { return nil }
        switch type {
        case .accumulator:
            return L10n.plrVoucherEarnTargetValueTitle
        default:
            return ""
        }
    }

    var earnTargetValueString: String? {
        guard let type = earnType else { return nil }
        switch type {
        case .accumulator:
            guard let value = voucher.earn?.targetValue?.floatValue else { return nil }
            return "\(voucher.earn?.prefix ?? "")\(String(format: "%.02f", value)) \(voucher.earn?.suffix ?? "")"
        default:
            return nil
        }
    }

    var dateText: String? {
        switch voucherState {
        case .expired, .cancelled:
            guard voucher.expiryDate != 0 else { return nil }
            return String.fromTimestamp(voucher.expiryDate?.doubleValue, withFormat: .dayShortMonthYear, prefix: L10n.plrVoucherDatePrefix)
        case .redeemed:
            guard voucher.dateRedeemed != 0 else { return nil }
            return String.fromTimestamp(voucher.dateRedeemed?.doubleValue, withFormat: .dayShortMonthYear, prefix: L10n.plrVoucherDatePrefix)
        default:
            return nil
        }
    }
}
