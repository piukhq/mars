//
//  LoginWorker.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit
import Alamofire
import Keys

struct Constants {
    static let endpoint = "https://api.bink-dev.com/ubiquity"
}

class LoginRepository {
    var user: Dictionary<String, Any>?

    func reigster(email: String, completion: @escaping (Any) -> Void) {
        let header = [
            "Authorization": "Bearer " + generateToken(email: email),
            "Content-Type": "application/json"]

        let parameters = [
            "consent": [
                "email": email,
                "latitude": 51.405372,
                "longitude": 0.00001,
                "timestamp": Date().timeIntervalSince1970.stringFromTimeInterval()
            ]
        ]
        Alamofire.request(Constants.endpoint + "/service", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header )
            .responseJSON { response in
                completion(response)
        }
    }
}

private extension LoginRepository {
    func generateToken(email: String) -> String {
        let keys = BinkappKeys()
        let header = [
            "alg": "HS512",
            "typ": "JWT"]

        // Encode header
        var headerDataEncoded: String?
        do {
            let headerData = try JSONSerialization.data(withJSONObject: header, options: JSONSerialization.WritingOptions.prettyPrinted)
            let headerDataEncodedWithEquals = headerData.base64EncodedString()
            headerDataEncoded = headerDataEncodedWithEquals.replacingOccurrences(of: "=", with: "")
        } catch {
            print("Could not make header data")
        }

        let payload = [
            "organisation_id": keys.organisationIdKey,
            "bundle_id": keys.bundleIdKey,
            "user_id": email,
            "property_id": keys.propertyIdKey,
            "iat": Date().timeIntervalSince1970.stringFromTimeInterval()]

        // Encode payload
        var payloadDataEncoded: String?
        do {
            let payloadData = try JSONSerialization.data(withJSONObject: payload, options: JSONSerialization.WritingOptions.prettyPrinted)
            payloadDataEncoded = payloadData.base64EncodedString()
        } catch {
            print("Could not make payload data")
        }
        if let encodedHeader = headerDataEncoded, let encodedPayload = payloadDataEncoded {
            let hmackString = encodedHeader + "." + encodedPayload
            let hexSignature = hmackString.hmac(algorithm: .SHA512, key: keys.secretKey)
            let signatureData = hexSignature.hexadecimal
            let signature = signatureData?.base64EncodedString().replacingOccurrences(of: "=", with: "") ?? ""
            let token  = hmackString + "." + signature
            print(token)
            return token
        }
        return ""
    }
}
