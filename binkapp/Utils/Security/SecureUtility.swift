//
//  SecureUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 27/02/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

final class SecureUtility {
    static func getPaymentCardHash(from paymentCard: PaymentCardCreateModel) -> String? {
        // get secret1 from cocoapods keys
        // base64 encode and save to keychain
        // base64 decode to read and use here
        let secret = "secret1"
        guard let pan = paymentCard.fullPan?.replacingOccurrences(of: " ", with: "") else { return nil }
        guard let month = paymentCard.month else { return nil }
        guard let year = paymentCard.year else { return nil }
        return "\(pan)\(month)\(year)\(secret)".sha512()
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
