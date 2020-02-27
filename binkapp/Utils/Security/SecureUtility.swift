//
//  SecureUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 27/02/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

final class SecureUtility {
    static func getPaymentCardHash(from paymentCard: PaymentCardCreateModel) -> String {
        // pan should have passed luhn check at this point
        // does expiry need to strip out "/" character?
        // need to get secret1 from keychain for the necessary environment
        // how are we storing the secret in the keychain?
        return ""
    }

    static func encryptAddPaymentCardRequestFieldValue(_ value: String) -> String {
        // get encryption key from keychain for right environment
        // encrypt value
        return ""
    }
}
