import Foundation

@objc(CD_Voucher)
open class CD_Voucher: _CD_Voucher {
    var balanceString: String? {
        switch earnType {
        case .accumulator:
            var suffix = ""
            if let earnSuffix = earn?.suffix {
                suffix = " \(earnSuffix)"
            }
            return "\(earn?.prefix ?? "")\(earn?.value?.twoDecimalPointString() ?? "")/\(earn?.targetValue?.twoDecimalPointString() ?? "")\(suffix)"
        case .stamps:
            var suffix = ""
            if let earnSuffix = earn?.suffix {
                suffix = " \(earnSuffix)"
            }
            return "\(earn?.prefix ?? "")\(earn?.value ?? 0)/\(earn?.targetValue ?? 0)\(suffix)"
        default:
            return nil
        }
    }

    var earnType: VoucherEarnType? {
        return VoucherEarnType(rawValue: earn?.type ?? "")
    }
}
