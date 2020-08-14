import Foundation

@objc(CD_PaymentCardCard)
open class CD_PaymentCardCard: _CD_PaymentCardCard {
	// Custom logic goes here.
    
    var paymentSchemeIdentifier: Int? {
        // Force to lowercased to futureproof against case-changes later
        switch provider?.lowercased() {
        case "visa":
            return 0
        case "mastercard":
            return 1
        case "amex":
            return 2
        default: return nil
        }
    }
}
