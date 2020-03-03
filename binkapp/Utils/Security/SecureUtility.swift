//
//  SecureUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 27/02/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import Keys
import SwiftyRSA

final class SecureUtility {

    static func getPaymentCardHash(from paymentCard: PaymentCardCreateModel) -> String? {
        guard let pan = paymentCard.fullPan?.replacingOccurrences(of: " ", with: "") else { return nil }
        guard let month = paymentCard.month else { return nil }
        guard let year = paymentCard.year else { return nil }
        // TODO: Get correct secret for environment
        guard let decodedSecret = BinkappKeys().devPaymentCardHashingSecret1.base64Decoded() else { return nil }
        let hash = "\(pan)\(month)\(year)\(decodedSecret)".sha512()
        return hash
    }

    static func encryptedSensitiveFieldValue(_ value: String?) -> String? {
        guard let value = value else { return nil }
        do {
            // TODO: Get correct public key for environment
            let publicKey = try PublicKey(derNamed: "devPublicKey")
            let clear = try ClearMessage(string: value, using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
            return encrypted.base64String
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}

extension String {
    func base64Decoded() -> String? {
        guard let decodedData = Data(base64Encoded: self) else { return nil }
        guard let decodedString = String(data: decodedData, encoding: .utf8) else { return nil }
        return decodedString
    }

    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
}
