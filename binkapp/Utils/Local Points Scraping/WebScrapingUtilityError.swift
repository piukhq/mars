//
//  WebScrapingUtilityError.swift
//  binkapp
//
//  Created by Nick Farrant on 03/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

enum WebScrapingUtilityErrorLevel {
    case client
    case site
    case user
}

enum WebScrapingUtilityError: BinkError {
    case agentProvidedInvalidUrl
    case scriptFileNotFound
    case failedToExecuteScript
    case failedToCastReturnValue
    case failedToAssignWebView
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
        switch self {
        case .agentProvidedInvalidUrl:
            return "Agent provided invalid URL"
        case .scriptFileNotFound:
            return "Script file not found"
        case .failedToExecuteScript:
            return "Failed to execute script"
        case .failedToCastReturnValue:
            return "Failed to cast return value"
        case .failedToAssignWebView:
            return "Failed to assign web view"
        case .userDismissedWebView:
            return "User dismissed web view for user action"
        case .unhandledIdling:
            return "Unhandled idling"
        case .javascriptError:
            return "Javascript error"
        case .noJavascriptResponse:
            return "No javascript response"
        case .failedToDecodeJavascripResponse:
            return "Failed to decode javascript response"
        case .incorrectCredentials(let errorMessage):
            return "Login failed - incorrect credentials. Error message: \(errorMessage ?? "")"
        case .genericFailure(let errorMessage):
            return "Local points collection uncategorized failure. Error message: \(errorMessage ?? "")"
        }
    }
    
    var level: WebScrapingUtilityErrorLevel {
        switch self {
        case .agentProvidedInvalidUrl, .scriptFileNotFound, .failedToExecuteScript, .javascriptError, .failedToDecodeJavascripResponse, .failedToAssignWebView:
            return .client
        case .failedToCastReturnValue, .genericFailure, .unhandledIdling, .noJavascriptResponse:
            return .site
        case .userDismissedWebView, .incorrectCredentials:
            return .user
        }
    }
}
