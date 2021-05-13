//
//  NetworkingError.swift
//  binkapp
//
//  Created by Nick Farrant on 15/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

enum NetworkingError: BinkError {
    case invalidRequest
    case unauthorized
    case noInternetConnection
    case methodNotAllowed
    case invalidUrl
    case sslPinningFailure
    case invalidResponse
    case decodingError
    case clientError(Int)
    case serverError(Int)
    case checkStatusCode(Int)
    case customError(String)
    case userFacingError(UserFacingNetworkingError)


    var domain: BinkErrorDomain {
        return .networking
    }

    var message: String {
        switch self {
        case .invalidRequest:
            return "Invalid request"
        case .unauthorized:
            return "Request unauthorized"
        case .noInternetConnection:
            return "No internet connection"
        case .methodNotAllowed:
            return "Method not allowed"
        case .invalidUrl:
            return "Invalid URL"
        case .sslPinningFailure:
            return "SSL pinning failure"
        case .invalidResponse:
            return "Invalid response"
        case .decodingError:
            return "Decoding error"
        case .clientError(let status):
            return "Client error with status code \(String(status))"
        case .serverError(let status):
            return "Server error with status code \(String(status))"
        case .checkStatusCode(let status):
            return "Error with status code \(String(status))"
        case .customError(let message):
            return message
        case .userFacingError(let error):
            return error.rawValue
        }
    }
}

/// A convenience object for errors returned from the API that we explicitly want to present to the user.
enum UserFacingNetworkingError: String {
    case planAlreadyLinked = "PLAN_ALREADY_LINKED"
    
    var title: String {
        switch self {
        case .planAlreadyLinked:
            return L10n.cardAlreadyLinkedTitle
        }
    }
    
    var message: String {
        switch self {
        default:
            return ""
        }
    }
    
    func message(membershipPlan: CD_MembershipPlan?) -> String {
        let planName = membershipPlan?.account?.planName ?? ""
        let planNameCard = membershipPlan?.account?.planNameCard ?? ""
        let planDetails = "\(planName) \(planNameCard)"
        return L10n.cardAlreadyLinkedMessage(L10n.cardAlreadyLinkedMessagePrefix, planDetails, planDetails)
    }
    
    static func errorForKey(_ errorKey: String) -> UserFacingNetworkingError? {
        return UserFacingNetworkingError(rawValue: errorKey)
    }
}
