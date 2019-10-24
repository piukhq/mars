import Foundation

@objc(CD_PaymentCard)
open class CD_PaymentCard: _CD_PaymentCard, WalletCardProtocol {
    // Custom logic goes here.

    var type: WalletCardType {
        return .payment
    }
}
