import Foundation

@objc(CD_MembershipCard)
open class CD_MembershipCard: _CD_MembershipCard, WalletCardProtocol {
    var type: WalletCardType {
        return .loyalty
    }

    func image(ofType type: ImageType) -> CD_MembershipCardImage? {
        return images.filtered(using: NSPredicate(format: "type == %@", NSNumber(value: type.rawValue))).first as? CD_MembershipCardImage
    }
    
    var formattedLinkedPaymentCards: [CD_PaymentCard]? {
        return linkedPaymentCards.allObjects as? [CD_PaymentCard]
    }
    
    var formattedTransactions: Set<CD_MembershipTransaction>? {
        return transactions as? Set<CD_MembershipTransaction>
    }

    var sortedVouchers: [CD_Voucher]? {
        guard let vouchers = vouchers.allObjects as? [CD_Voucher] else { return nil }
        return vouchers.sorted {
            guard let state1 = VoucherState(rawValue: $0.state ?? "") else { return false }
            guard let state2 = VoucherState(rawValue: $1.state ?? "") else { return false }

            if state1.sort != state2.sort {
                return state1.sort < state2.sort
            } else {
                return $0.id > $1.id
            }
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
        let expiryDateDescriptor = NSSortDescriptor(key: "expiryDate", ascending: false)
        if let inactiveVouchers = filteredVouchers as NSArray? {
            return inactiveVouchers.sortedArray(using: [expiryDateDescriptor, redeemDateDescriptor]) as? [CD_Voucher]
        }
        return filteredVouchers
    }
    
    var vouchersEarnType: VoucherEarnType? {
        return sortedVouchers?.first?.earnType
    }
    
    var formattedBalances: [CD_MembershipCardBalance]? {
        return balances.allObjects as? [CD_MembershipCardBalance]
    }
}
