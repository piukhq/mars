import Foundation

@objc(CD_PaymentCard)
open class CD_PaymentCard: _CD_PaymentCard, WalletCardProtocol {
    var type: WalletCardType {
        return .payment
    }
}
