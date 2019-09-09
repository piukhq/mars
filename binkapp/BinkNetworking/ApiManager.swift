//
//  BaseRequest.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import Keys
import Alamofire

enum RequestURL {
    case login
    case membershipPlans
    case membershipCards
    case deleteMembershipCard(cardId: Int)
    case postMembershipCard
    
    var value: String {
        switch self {
        case .login: return "/service"
        case .membershipPlans: return "/membership_plans"
        case .membershipCards: return "/membership_cards"
        case .deleteMembershipCard(let cardId): return "/membership_card/\(cardId)"
        case .postMembershipCard: return "/membership_cards"
        }
    }
}

enum RequestHTTPMethod {
    case get
    case post
    case put
    case delete
    case patch
    
    var value: HTTPMethod {
        switch self {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .delete: return .delete
        case .patch: return .patch
        }
    }
}

class ApiManager {
    private let email = "Bink20iteration1@testbink.com"
    
    func doRequest<Resp>(url: RequestURL, httpMethod: RequestHTTPMethod, parameters: [String: Any]? = nil, onSuccess: @escaping (Resp) -> (), onError: @escaping (Error) -> () = { _ in }) where Resp: Codable {
        var params: [String: Any]?
        if parameters == nil {
            params = getParameters()
        } else {
            params = parameters
        }
        Alamofire.request(Constants.endpoint + "\(url.value)", method: httpMethod.value, parameters: params, encoding: JSONEncoding.default, headers: getHeader() )
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
                        let models = try decoder.decode(Resp.self, from: data)
                        onSuccess(models)
                    } else if let error = response.error {
                        print(error)
                        onError(error)
                    } else {
                        print("something went wrong, statusCode: \(statusCode)")
                    }
                } catch (let error) {
                    print("decoding error: \(error)")
                    onError(error)
                }
        }
    }
}

private extension ApiManager {
    private func getHeader() -> [String : String] {
        let header = [
            "Authorization": "Bearer " + generateToken(email: email),
            "Content-Type": "application/json"]
        return header
    }
    
    private func getParameters() -> [String : [String : Any]] {
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
    
    private func generateToken(email: String) -> String {
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
