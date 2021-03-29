//
//  WebScrapingUtilityError.swift
//  binkapp
//
//  Created by Nick Farrant on 03/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

// TODO: Separate client vs JS errors in sentry

enum WebScrapingUtilityError: BinkError {
    case agentProvidedInvalidUrl
    case scriptFileNotFound
    case failedToExecuteScript
    case failedToCastReturnValue
    case userDismissedWebView
    case unhandledIdling
    case javascriptError
    case noJavascriptResponse
    case failedToDecodeJavascripResponse
    case incorrectCredentials(errorMessage: String?)
    case genericFailure(errorMessage: String?)

    var domain: BinkErrorDomain {
        return .webScrapingUtility
    }

    var message: String {
        // TODO: Add messages here
        return ""
    }
}
