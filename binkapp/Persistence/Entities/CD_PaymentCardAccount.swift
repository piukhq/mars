import Foundation

@objc(CD_PaymentCardAccount)
open class CD_PaymentCardAccount: _CD_PaymentCardAccount {
    var formattedConsents: [CD_PaymentCardAccountConsents]? {
        return consents.allObjects as? [CD_PaymentCardAccountConsents]
    }
}
