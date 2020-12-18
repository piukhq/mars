import Foundation

@objc(CD_PaymentCard)
open class CD_PaymentCard: _CD_PaymentCard, WalletCardProtocol {
    // Custom logic goes here.

    var type: WalletCardType {
        return .payment
    }
    
    var paymentCardStatus: PaymentCardStatus {
        return PaymentCardStatus(rawValue: status ?? "") ?? .pending
    }

    var isExpired: Bool {
        guard let card = card,
            let expiryYear = card.year,
            let expiryMonth = card.month else {
                return false
        }
        guard let expiryDate = Date.makeDate(year: expiryYear.intValue, month: expiryMonth.intValue, day: 01, hr: 12, min: 00, sec: 00) else {
            return false
        }
        
        return expiryDate.isBefore(date: Date(), toGranularity: .month)
    }
}
