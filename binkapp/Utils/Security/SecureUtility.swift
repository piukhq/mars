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
        guard let decodedSecret = decodedSecret() else { return nil }
        let stringToHash = "\(pan)\(month)\(year)\(decodedSecret)"
        return stringToHash.sha512
    }

    static func encryptedSensitiveFieldValue(_ value: String?) -> String? {
        /// If we are pinning to API v1.1, just return the value without encryption
        if Current.apiClient.apiVersion == .v1_1 { return value }

        guard let value = value else { return nil }
        guard let publicKeyName = publicKeyName() else { return nil }
        do {
            let publicKey = try PublicKey(derNamed: publicKeyName)
            let clear = try ClearMessage(string: value, using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: .OAEP)
            return encrypted.base64String
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }

    /// Get the correct secret for the environment
    /// Return a base 64 decoded copy of the secret
    private static func decodedSecret() -> String? {
        if APIConstants.baseURLString == EnvironmentType.dev.rawValue {
            return BinkappKeys().devPaymentCardHashingSecret1.base64Decoded()
        } else if APIConstants.baseURLString == EnvironmentType.staging.rawValue {
            return BinkappKeys().stagingPaymentCardHashingSecret1.base64Decoded()
        } else if APIConstants.baseURLString == EnvironmentType.production.rawValue {
            return BinkappKeys().prodPaymentCardHashingSecret1.base64Decoded()
        } else {
            return nil
        }
    }

    private static func publicKeyName() -> String? {
        if APIConstants.baseURLString == EnvironmentType.dev.rawValue {
            return "devPublicKey"
        } else if APIConstants.baseURLString == EnvironmentType.staging.rawValue {
            return "stagingPublicKey"
        } else if APIConstants.baseURLString == EnvironmentType.production.rawValue {
            return "prodPublicKey"
        } else {
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
