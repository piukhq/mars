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
        guard let decodedSecret = BinkappKeys().devPaymentCardHashingSecret1.base64Decoded() else { return nil }
        return "\(pan)\(month)\(year)\(decodedSecret)".sha512()
    }

    static func encryptedSensitiveFieldValue(_ value: Any) -> String? {
        let publicKeyString = """
        -----BEGIN PUBLIC KEY-----
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAkuwzWAdw2+t7gAy+ciSQ
        IOtqvEg3C23cWnjHZpe465ZUJmnyW5B5HBJVLd+A0fpVlujkwowwvZ4GjAP8J0hY
        0wYi8yCvGGD8CJ2XPqyfv/w+kOr/AnpWOajFMe0tA65Q2xs77N2JrwPAv/Cyr8Iu
        QK/6B4QjB21nf6RkoxR8uFm7AQbxFa2EpWpBswbU0J2hXWiYSLJOcSAxs0/8e6SQ
        1Kz50nZe1GcQebOx1DD6F2XtIy4Z/klJ8X2OeJrOblTjFnOYw0F+NHk0FTChTA4U
        yypM5tZ3jxSQVEPxTyqXYF00mHJP1WsPGiYIpRfgbnUDkZwpM2+4+hIc5Q4OK8wH
        N6dacU0dQqBcao9BZwWgQdwUSVUTwYYuwLjXV0ApfOrU1fXDnoG3ZJcP1jTqxygT
        Nwuwn28sRujfWrOAcdukYMb3S4IpCvRupeJExh8Tuhwej10gIPaO+MoJcLqYns7F
        aYjJtkzORjcyr4sBhNiektkQP76qUMn9aluJt0cbqXuREiL9cSahHACY0f3StoDg
        BrEprwvlkk+9E65rfOsBTiZ2chbHYlTYAzqVtSg8pcc5Dh9/xeFm7D75upWlpspZ
        C7RpZ2pBDx3vKnJKGg7qFlgdo58qvQJ0UQXOB9Qtn4pNR8U73t/uSThkPteqAUmg
        qXak680pVcC+wOsH4nQ3YtMCAwEAAQ==
        -----END PUBLIC KEY-----
        """
        guard let base64PublicKey = publicKeyString.base64Encoded() else {
            return nil
        }
        guard let publicKey = try? PublicKey(base64Encoded: base64PublicKey) else {
            return nil
        }
        guard let clear = try? ClearMessage(string: "Clear Text", using: .utf8) else {
            return nil
        }
        guard let encrypted = try? clear.encrypted(with: publicKey, padding: .PKCS1) else {
            return nil
        }

        return encrypted.base64String
    }

    static func encryptedSensitiveFieldValue(_ value: Any) -> Int {
        return 0
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
