import Foundation

@objc(CD_MembershipCard)
open class CD_MembershipCard: _CD_MembershipCard, WalletCardProtocol {
    var type: WalletCardType {
        return .loyalty
    }

	// Custom logic goes here.
    var formattedBalances: Set<CD_MembershipCardBalance>? {
        return balances as? Set<CD_MembershipCardBalance>
    }
    
    var formattedTransactions: Set<CD_MembershipTransaction>? {
        return transactions as? Set<CD_MembershipTransaction>
    }

    var sortedVouchers: [CD_Voucher]? {
        guard let vouchers = vouchers.allObjects as? [CD_Voucher] else { return nil }
        // TODO: We need to find a sort order from something, otherwise we run into indexPath issues
        return vouchers
    }

    // State == .issued or .inProgress
    var activeVouchers: [CD_Voucher]? {
        guard let vouchers = sortedVouchers else { return nil }
        return vouchers.filter { $0.state == VoucherState.issued.rawValue || $0.state == VoucherState.inProgress.rawValue }
    }

    // State == .cancelled or .redeemed or .expired
    var inactiveVouchers: [CD_Voucher]? {
        guard let vouchers = sortedVouchers else { return nil }
        return vouchers.filter { $0.state == VoucherState.redeemed.rawValue || $0.state == VoucherState.cancelled.rawValue || $0.state == VoucherState.expired.rawValue }
    }
}
