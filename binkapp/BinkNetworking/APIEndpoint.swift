//
//  APIEndpoint.swift
//  binkapp
//
//  Created by Nick Farrant on 15/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import Keys
import Alamofire

enum APIEndpoint: Equatable {
    case service
    case login
    case register
    case facebook
    case apple
    case logout
    case renew
    case me
    case preferences
    case forgotPassword
    case membershipPlans
    case membershipCards
    case membershipCard(cardId: String)
    case paymentCards
    case paymentCard(cardId: String)
    case linkMembershipCardToPaymentCard(membershipCardId: String, paymentCardId: String)
    case spreedly

    var headers: [String: String] {
        // TODO: Don't hardcode the headers
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json\(shouldVersionPin ? ";\(Current.apiClient.apiVersion.rawValue)" : "")",
            "User-Agent": "Bink App / iOS \(Bundle.shortVersionNumber ?? "") / \(UIDevice.current.systemVersion)"
        ]

        if authRequired {
            guard let token = Current.userManager.currentToken else { return headers }
            headers["Authorization"] = "Token " + token
        }

        return headers
    }

    // TODO: Split per endpoints
    var allowedMethods: [HTTPMethod] {
        return [.get, .post, .put, .patch, .delete]
    }

    var urlString: String? {
        guard usesComponents else {
            return path
        }
        var components = URLComponents()
        components.scheme = scheme

        components.host = APIConstants.baseURLString
        components.path = path
        return components.url?.absoluteString.removingPercentEncoding
    }
    
    func urlString(withQueryParameters params: [String: String]) -> String? {
        guard usesComponents else {
            return path
        }
        var components = URLComponents()
        components.scheme = scheme
        
        components.host = APIConstants.baseURLString
        components.path = path
        components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components.url?.absoluteString.removingPercentEncoding
    }

    /// There are cases where an endpoint requires authorization, but shouldn't respond to a 401 response code such as .logout.
    var shouldRespondToUnauthorizedStatus: Bool {
        switch self {
        case .logout:
            return false
        default: return true
        }
    }

    private var authRequired: Bool {
        switch self {
        case .register, .login, .renew, .spreedly:
            return false
        default: return true
        }
    }

    public var shouldVersionPin: Bool {
        switch self {
        case .spreedly:
            return false
        default: return true
        }
    }

    private var usesComponents: Bool {
        switch self {
        case .spreedly:
            return false
        default: return true
        }
    }

    private var scheme: String {
        return "https"
    }

    private var path: String {
        switch self {
        case .service:
            return "/ubiquity/service"
        case .login:
            return "/users/login"
        case .register:
            return "/users/register"
        case .facebook:
            return "/users/auth/facebook"
        case .apple:
            return "/users/auth/apple"
        case .logout:
            return "/users/me/logout"
        case .renew:
            return "/users/renew_token"
        case .me:
            return "/users/me"
        case .preferences:
            return "/users/me/settings"
        case .forgotPassword:
            return "/users/forgotten_password"
        case .membershipPlans:
            return "/ubiquity/membership_plans"
        case .membershipCards:
            return "/ubiquity/membership_cards"
        case .membershipCard(let cardId):
            return "/ubiquity/membership_card/\(cardId)"
        case .paymentCards:
            return "/ubiquity/payment_cards"
        case .paymentCard(let cardId):
            return "/ubiquity/payment_card/\(cardId)"
        case .linkMembershipCardToPaymentCard(let membershipCardId, let paymentCardId):
            return "/ubiquity/membership_card/\(membershipCardId)/payment_card/\(paymentCardId)"
        case .spreedly:
            return "https://core.spreedly.com/v1/payment_methods?environment_key=\(BinkappKeys().spreedlyEnvironmentKey)"
        }
    }
}
