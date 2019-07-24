//
//  LoginWorker.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit
import Alamofire

struct Constants {
    //TODO: Get this from Cocoapods-Keys
    static let emailAddress = "Bink20iteration1@testbink.com"
    static let endpoint = "https://api.bink-dev.com/ubiquity/service"
    static let organisationID = "Loyalty Angels"
    static let property_id = "Bink2.0"
    static let secret = "QFUkKGnW8SECYwKRVWqrQKlaogNakK4IqEun09GoFRBlhyimsw"
    static let bundle_id = "com.bink.bink20dev"
}

class LoginWorker {
    func login(email: String) {
        let header = [
            "Authorization": "Bearer " + generateToken()]
        Alamofire.request(Constants.endpoint, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: header )
            .responseString { response in
                print("response \(response)")
        }
    }
}

// Private extension for LoginWorker class
private extension LoginWorker {
    func generateToken() -> String {
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
            "organisation_id": Constants.organisationID,
            "bundle_id": Constants.bundle_id,
            "user_id": Constants.emailAddress,
            "property_id": Constants.property_id,
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
            let hexSignature = hmackString.hmac(algorithm: .SHA512, key: Constants.secret)
            let signatureData = hexSignature.hexadecimal
            let signature = signatureData?.base64EncodedString().replacingOccurrences(of: "=", with: "") ?? ""
            let token  = hmackString + "." + signature
            return token
        }
        return ""
    }
}
