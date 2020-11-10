import Foundation

@objc(CD_Voucher)
open class CD_Voucher: _CD_Voucher {
    var balanceString: String? {
        var suffix = ""
        if let earnSuffix = earn?.suffix {
            suffix = " \(earnSuffix)"
        }
        switch earnType {
        case .accumulator:
            return "\(earn?.prefix ?? "")\(earn?.value?.twoDecimalPointString() ?? "")/\(earn?.prefix ?? "")\(earn?.targetValue?.twoDecimalPointString() ?? "")\(suffix)"
        case .stamps:
            return "\(earn?.prefix ?? "")\(earn?.value ?? 0)/\(earn?.prefix ?? "")\(earn?.targetValue ?? 0)\(suffix)"
        default:
            return nil
        }
    }
    
    var voucherState: VoucherState? {
        return VoucherState(rawValue: state ?? "")
    }
    
    var formattedHeadline: String? {
        let prefix = earn?.prefix ?? ""
        let targetValue = earn?.targetValue?.doubleValue ?? 0.0
        let value = earn?.value?.doubleValue ?? 0.0
        let displayValue = NSNumber(value: targetValue - value)
        let displayValueString = displayValue.twoDecimalPointString()
        
        var suffix = ""
        if let earnSuffix = earn?.suffix {
            suffix = " \(earnSuffix)"
        }
        
        switch (earnType, voucherState) {
        case (.stamps, .inProgress):
            return String(format: displayValue.intValue > 1 ? "plr_stamp_voucher_headline_plural".localized : "plr_stamp_voucher_headline".localized, prefix, displayValueString)
        case (.accumulator, .inProgress):
            return String(format: "plr_accumulator_voucher_headline".localized, prefix, displayValueString, suffix)
        case (_, .issued):
            return "plr_issued_headline".localized
        default:
            return voucherState?.rawValue.capitalized
        }
    }

    var earnType: VoucherEarnType? {
        return VoucherEarnType(rawValue: earn?.type ?? "")
    }
}
