//
//  NetworkingError.swift
//  binkapp
//
//  Created by Nick Farrant on 15/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

enum NetworkingError: BinkError {
    case unauthorized
    case noInternetConnection
    case methodNotAllowed
    case invalidUrl
    case sslPinningFailure
    case invalidResponse
    case decodingError
    case clientError(Int?)
    case serverError(Int?)
    case checkStatusCode(Int)
    case customError(String?)

    var domain: BinkErrorDomain {
        return .networking
    }

    var errorCode: String? {
        return nil
    }

    var message: String? {
        switch self {
        case .customError(let message):
            return message
        default: return nil
        }
    }
}
