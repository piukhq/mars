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

enum UserFacingNetworkingError: String {
    case planAlreadyLinked = "PLAN_ALREADY_LINKED"
    
    var message: String {
        switch self {
        case .planAlreadyLinked:
            return "card_already_linked_message"
        }
    }
    
    static func errorForKey(_ errorKey: String) -> UserFacingNetworkingError? {
        return UserFacingNetworkingError(rawValue: errorKey)
    }
}

enum UserFacingNetworkingErrorForMultiplePaymentCards: String {
    case planAlreadyLinked = "PLAN_ALREADY_LINKED"
    
    var message: String {
        switch self {
        case .planAlreadyLinked:
            return "cards_already_linked_message"
        }
    }
    
    static func errorForKey(_ errorKey: String) -> UserFacingNetworkingErrorForMultiplePaymentCards? {
        return UserFacingNetworkingErrorForMultiplePaymentCards(rawValue: errorKey)
    }
}
