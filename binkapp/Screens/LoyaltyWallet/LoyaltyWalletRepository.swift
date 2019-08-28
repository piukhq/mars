//
//  LoyaltyWalletRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import Alamofire
import Keys

class LoyaltyWalletRepository {
    let email = "Bink20iteration1@testbink.com"
    
    func getHeader() -> [String : String] {
        let header = [
            "Authorization": "Bearer " + generateToken(email: email),
            "Content-Type": "application/json"]
        return header
    }
    
    func getParameters() -> [String : [String : Any]] {
        let parameters = [
            "consent": [
                "email": email,
                "latitude": 51.405372,
                "longitude": 0.00001,
                "timestamp": Date().timeIntervalSince1970.stringFromTimeInterval()
            ]
        ]
        
        return parameters
    }
    
    func getMembershipCards(completion: @escaping ([MembershipCardModel]) -> Void) {
        Alamofire.request(Constants.endpoint + "/membership_cards", method: .get, parameters: getParameters(), encoding: JSONEncoding.default, headers: getHeader() )
            .responseJSON { response in
                guard let data = response.data else {
                    print("No data found")
                    return
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys

                do {
                    let statusCode = response.response?.statusCode ?? 0
                    if statusCode == 200 || statusCode == 201 {
                        let models = try decoder.decode([MembershipCardModel].self, from: data)
                        completion(models)
                    } else if let error = response.error {
                        print(error)
                    } else {
                        print("something went wrong, statusCode: \(statusCode)")
                    }
                } catch (let error) {
                    print("decoding error: \(error)")
                }
        }
    }
    
    func getMembershipPlans(completion: @escaping ([MembershipPlanModel]) -> Void ){
        Alamofire.request(Constants.endpoint + "/membership_plans", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: getHeader() )
            .responseJSON { response in
                guard let data = response.data else {
                    print("No data found")
                    return
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys
                
                do {
                    let statusCode = response.response?.statusCode ?? 0
                    if statusCode == 200 {
                        let models = try decoder.decode([MembershipPlanModel].self, from: data)
                        completion(models)
                    } else if let error = response.error {
                        print(error)
                    } else {
                        print("something went wrong, statusCode: \(statusCode)")
                    }
                } catch (let error) {
                    print("decoding error: \(error)")
                }
        }
    }
    
    func deleteMembershipCard(id: Int, completion: @escaping (Any) -> Void) {
        Alamofire.request(Constants.endpoint + "/membership_card/\(id)", method: .get, parameters: getParameters(), encoding: JSONEncoding.default, headers: getHeader() )
            .responseJSON { response in
                completion(response)
        }
    }
}

extension LoyaltyWalletRepository {
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
            return token
        }
        return ""
    }
}
