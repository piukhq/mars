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
            return "\(earn?.prefix ?? "")\(Int(truncating: earn?.value ?? 0))/\(earn?.prefix ?? "")\(earn?.targetValue ?? 0)\(suffix)"
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
            let roundedDisplayValue = Int(displayValue.floatValue.rounded())
            return Int(displayValue.floatValue.rounded()) > 1 ? L10n.plrStampVoucherHeadlinePlural(prefix, roundedDisplayValue) : L10n.plrStampVoucherHeadline(prefix, roundedDisplayValue)
        case (.accumulator, .inProgress):
            return L10n.plrAccumulatorVoucherHeadline(prefix, displayValueString, suffix)
        case (_, .issued):
            return L10n.plrIssuedHeadline
        default:
            return voucherState?.rawValue.capitalized
        }
    }

    var earnType: VoucherEarnType? {
        return VoucherEarnType(rawValue: earn?.type ?? "")
    }
}
