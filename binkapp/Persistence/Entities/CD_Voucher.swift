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
            return "\(earn?.prefix ?? "")\(earn?.value?.twoDecimalPointString() ?? "")/\(earn?.targetValue?.twoDecimalPointString() ?? "")\(suffix)"
        case .stamps:
            return "\(earn?.prefix ?? "")\(earn?.value ?? 0)/\(earn?.targetValue ?? 0)\(suffix)"
        default:
            return nil
        }
    }

    var earnType: VoucherEarnType? {
        return VoucherEarnType(rawValue: earn?.type ?? "")
    }
}
