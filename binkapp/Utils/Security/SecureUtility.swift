//
//  SecureUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 27/02/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

final class SecureUtility {
    static func
        getPaymentCardHash(from paymentCard: PaymentCardCreateModel) -> String {
        // need to get secret1 from keychain for the necessary environment
        // how are we storing the secret in the keychain?
        let secret = "secret1"
        return "\(paymentCard.fullPan ?? "")\(paymentCard.month ?? 0)\(paymentCard.year ?? 0)\(secret)".sha512()
    }

    static func encryptedSensitiveFieldValue(_ value: Any) -> String {
        // get encryption key from keychain for right environment
        // encrypt value
        return ""
    }

    static func encryptedSensitiveFieldValue(_ value: Any) -> Int {
        // get encryption key from keychain for right environment
        // encrypt value
        return 0
    }
}
