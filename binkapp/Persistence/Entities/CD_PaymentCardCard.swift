import Foundation

@objc(CD_PaymentCardCard)
open class CD_PaymentCardCard: _CD_PaymentCardCard {
	// Custom logic goes here.
    
    enum PaymentCardProvider: String, Codable {
        case visa = "Visa"
        case americanexpress = "American Express"
        case mastercard = "Mastercard"
    }
    
    var providerName: PaymentCardProvider? {
        guard let provider = provider else { return nil }
        
        return PaymentCardProvider(rawValue: provider)
    }
}
