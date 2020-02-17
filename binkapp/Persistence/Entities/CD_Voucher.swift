import Foundation

@objc(CD_Voucher)
open class CD_Voucher: _CD_Voucher {
    var balanceString: String? {
        switch earnType {
        case .accumulator:
            return "\(earn?.prefix ?? "")\(earn?.value?.twoDecimalPointString() ?? "")/\(earn?.prefix ?? "")\(earn?.targetValue?.twoDecimalPointString() ?? "") \(earn?.suffix ?? "")"
        case .stamp:
            return "\(earn?.value ?? 0)/\(earn?.targetValue ?? 0) \(earn?.suffix?.capitalized ?? "")"
        default:
            return nil
        }
    }

    var earnType: VoucherEarnType? {
        return VoucherEarnType(rawValue: earn?.type ?? "")
    }
}
