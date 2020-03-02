//
//  SecureUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 27/02/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import Keys

final class SecureUtility {
    static func getPaymentCardHash(from paymentCard: PaymentCardCreateModel) -> String? {
        guard let pan = paymentCard.fullPan?.replacingOccurrences(of: " ", with: "") else { return nil }
        guard let month = paymentCard.month else { return nil }
        guard let year = paymentCard.year else { return nil }
        guard let decodedSecret = BinkappKeys().devPaymentCardHashingSecret1.base64Decoded() else { return nil }
        return "\(pan)\(month)\(year)\(decodedSecret)".sha512()
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

extension String {
    func base64Decoded() -> String? {
        guard let decodedData = Data(base64Encoded: self) else { return nil }
        guard let decodedString = String(data: decodedData, encoding: .utf8) else { return nil }
        return decodedString
    }
}
