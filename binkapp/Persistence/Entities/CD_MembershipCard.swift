import Foundation

@objc(CD_MembershipCard)
open class CD_MembershipCard: _CD_MembershipCard, WalletCardProtocol {
    var type: WalletCardType {
        return .loyalty
    }

    func image(ofType type: ImageType) -> CD_MembershipCardImage? {
        return images.filtered(using: NSPredicate(format: "type == %@", NSNumber(integerLiteral: type.rawValue))).first as? CD_MembershipCardImage
    }
    
    var formattedBalances: Set<CD_MembershipCardBalance>? {
        return balances as? Set<CD_MembershipCardBalance>
    }
    
    var formattedTransactions: Set<CD_MembershipTransaction>? {
        return transactions as? Set<CD_MembershipTransaction>
    }

    var sortedVouchers: [CD_Voucher]? {
        guard let vouchers = vouchers.allObjects as? [CD_Voucher] else { return nil }
        return vouchers.sorted { (voucher1, voucher2) -> Bool in
            return voucher1.id < voucher2.id
        }
    }

    // State == .issued or .inProgress
    var activeVouchers: [CD_Voucher]? {
        guard let vouchers = sortedVouchers else { return nil }
        return vouchers.filter { $0.state == VoucherState.issued.rawValue || $0.state == VoucherState.inProgress.rawValue }
    }

    // State == .cancelled or .redeemed or .expired
    var inactiveVouchers: [CD_Voucher]? {
        guard let vouchers = sortedVouchers else { return nil }
        let filteredVouchers = vouchers.filter { $0.state == VoucherState.redeemed.rawValue || $0.state == VoucherState.cancelled.rawValue || $0.state == VoucherState.expired.rawValue }
        let redeemDateDescriptor = NSSortDescriptor(key: "dateRedeemed", ascending: false)
        let expiryDateDescriptor =  NSSortDescriptor(key: "expiryDate", ascending: false)
        if let inactiveVouchers = filteredVouchers as NSArray? {
            return inactiveVouchers.sortedArray(using: [expiryDateDescriptor, redeemDateDescriptor]) as? [CD_Voucher]
        }
        return filteredVouchers
    }
    
    var vouchersEarnType: VoucherEarnType? {
        return sortedVouchers?.first?.earnType
    }
}
