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

    var domain: BinkErrorDomain {
        return .networking
    }

    var errorCode: String {
        switch self {
        case .unauthorized:
            return "N101"
        }
    }

    var message: String {
        switch self {
        case .unauthorized:
            return ""
        }
    }
}
