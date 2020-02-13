import Foundation

@objc(CD_Voucher)
open class CD_Voucher: _CD_Voucher {
    var balanceString: String? {
        return "\(earn?.prefix ?? "")\(earn?.value?.twoDecimalPointString() ?? "")/\(earn?.prefix ?? "")\(earn?.targetValue?.twoDecimalPointString() ?? "") \(earn?.suffix ?? "")"
    }

    var earnType: VoucherEarnType? {
        return VoucherEarnType(rawValue: earn?.type ?? "")
    }
}
