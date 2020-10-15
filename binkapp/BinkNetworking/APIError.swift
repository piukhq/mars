//
//  APIError.swift
//  binkapp
//
//  Created by Sean Williams on 15/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

enum APIError: String {
    case planAlreadyLinked = "PLAN_ALREADY_LINKED"
    
    var userErrorMessage: String {
        switch self {
        case .planAlreadyLinked:
            return "This payment card is already linked to a different PLAN_NAME. Please unlink the other PLAN_NAME before proceeding, but be aware this may only be possible from another application."
        }
    }
    
    var userErrorMessageMultiple: String {
        switch self {
        case .planAlreadyLinked:
            return "One of these payment cards are already linked to a different PLAN_NAME. Please unlink the other PLAN_NAME before proceeding, but be aware this may only be possible from another application"
        }
    }
    
    static func errorForKey(_ errorKey: String) -> APIError? {
        return APIError(rawValue: errorKey)
    }
}
