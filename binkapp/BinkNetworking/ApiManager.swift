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
    case register
    case facebook
    case logout
    case renew
    case membershipPlans
    case membershipCards
    case membershipCard(cardId: String)
    case paymentCards
    case paymentCard(cardId: String)
    case linkMembershipCardToPaymentCard(membershipCardId: String, paymentCardId: String)
    
    var value: String {
        switch self {
        case .login:
            return "/users/login"
        case .register:
            return "/users/register"
        case .facebook:
            return "/users/auth/facebook"
        case .logout:
            return "/users/me/logout"
        case .renew:
            return "/users/renew_token"
        case .membershipPlans:
            return "/ubiquity/membership_plans"
        case .membershipCards:
            return "/membership_cards"
        case .membershipCard(let cardId):
            return "/membership_card/\(cardId)"
        case .paymentCards:
            return "/ubiquity/payment_cards"
        case .paymentCard(let cardId):
            return "/ubiquity/payment_card/\(cardId)"
        case .linkMembershipCardToPaymentCard(let membershipCardId, let paymentCardId):
            return "/ubiquity/membership_card/\(membershipCardId)/payment_card/\(paymentCardId)"
        }
    }
    
    func authRequired() -> Bool {
        switch self {
        case .register, .login, .renew:
            return false
        default:
            return true
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
    func doRequest<Resp>(url: RequestURL, httpMethod: RequestHTTPMethod, headers: [String: String]? = nil, parameters: [String: Any]? = nil, onSuccess: @escaping (Resp) -> (), onError: @escaping (Error) -> () = { _ in }) where Resp: Codable {
        guard Connectivity.isConnectedToInternet() else {
            NotificationCenter.default.post(name: .noInternetConnection, object: nil)
            return
        }
        
        let authRequired = url.authRequired()
        let requestHeaders = headers != nil ? headers : getHeader(authRequired: authRequired)
        
        Alamofire.request(APIConstants.baseURLString + "\(url.value)", method: httpMethod.value, parameters: parameters, encoding: JSONEncoding.default, headers: requestHeaders)
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
                    } else if statusCode == 403 && authRequired {
                        /*
                         If the endpoint expects an authorisation token,
                         ensure that we aggressively respond in app to a 403.
                         */
                        NotificationCenter.default.post(name: .shouldLogout, object: nil)
                    } else if let error = response.error {
                        print(error)
                        onError(error)
                    } else {
                        print("something went wrong, statusCode: \(statusCode)")
                        onError(NSError(domain: "", code: statusCode, userInfo: nil) as Error)
                    }
                } catch (let error) {
                    print("decoding error: \(error)")
                    onError(error)
                }
        }
    }
    
    
}

private extension ApiManager {
    private func getHeader(authRequired: Bool) -> [String: String]? {
        var header = ["Content-Type": "application/json;v=1.1"]
        
        if authRequired {
            guard let token = Current.userManager.currentToken() else { return nil }
            header["Authorization"] = "Token " + token
        }

        return header
    }
}
