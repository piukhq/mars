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
    case logout
    case renew
    case preferences
    case forgotPassword
    case membershipPlans
    case membershipCards
    case membershipCard(cardId: String)
    case paymentCards
    case paymentCard(cardId: String)
    case linkMembershipCardToPaymentCard(membershipCardId: String, paymentCardId: String)
    case spreedly

    var authRequired: Bool {
        switch self {
        case .register, .login, .renew, .spreedly:
            return false
        default:
            return true
        }
    }

    var headers: [String: String] {
        // TODO: Don't hardcode the headers
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json\(shouldVersionPin ? ";\(Current.apiManager.apiVersion.rawValue)" : "")"
        ]

        if authRequired {
            guard let token = Current.userManager.currentToken else { return headers }
            headers["Authorization"] = "Token " + token
        }

        return headers
    }

    var shouldVersionPin: Bool {
        switch self {
        case .spreedly:
            return false
        default:
            return true
        }
    }

    // TODO: Split per endpoints
    var allowedMethods: [HTTPMethod] {
        return [.get, .post, .put, .patch, .delete]
    }

    var fullUrlString: String {
        return "\(baseUrlString)\(value)"
    }

    private var baseUrlString: String {
        switch self {
        case .spreedly:
            return ""
        default:
            return APIConstants.baseURLString
        }
    }

    private var value: String {
        switch self {
        case .service:
            return "/ubiquity/service"
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
