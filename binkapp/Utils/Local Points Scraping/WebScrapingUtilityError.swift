//
//  WebScrapingUtilityError.swift
//  binkapp
//
//  Created by Nick Farrant on 03/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

enum WebScrapingUtilityError: BinkError {
    case agentProvidedInvalidUrl
    case loginScriptFileNotFound
    case scapingScriptFileNotFound
    case detectTextScriptFileNotFound
    case agentProvidedInvalidLoginScript
    case agentProvidedInvalidScrapeScript
    case invalidDetectTextScript
    case loginFailed(errorMessage: String?)
    case userDismissedWebView
    case unhandledIdling
    case pointsScrapingFailed(errorMessage: String?)

    var domain: BinkErrorDomain {
        return .webScrapingUtility
    }

    var message: String {
        switch self {
        case .agentProvidedInvalidUrl:
            return "Agent provided invalid URL"
        case .loginScriptFileNotFound:
            return "Login script file not found"
        case .scapingScriptFileNotFound:
            return "Scraping script file not found"
        case .agentProvidedInvalidLoginScript:
            return "Agent provided invalid login script"
        case .agentProvidedInvalidScrapeScript:
            return "Agent provided invalid scrape script"
        case .loginFailed(let errorMessage):
            if let error = errorMessage {
                return "Login failed - \(error)"
            }
            return "Login failed"
        case .detectTextScriptFileNotFound:
            return "Detect text script file not found"
        case .invalidDetectTextScript:
            return "Invalid detect text script"

        case .userDismissedWebView:
            return "User dismissed webview"
        case .unhandledIdling:
            return "Unhandled idling"
        case .pointsScrapingFailed(let errorMessage):
            if let error = errorMessage {
                return "Points scraping failed - \(error)"
            }
            return "Points scraping failed"
        }
    }
}

enum WebScrapingUtilityAgentError: BinkError {
    case javascriptError
    case failedToExecuteDetectTextScript
    case failedToCastReturnValue
    case failedToExecuteScrapingScript
    case failedToExecuteLoginScript

    var domain: BinkErrorDomain {
        return .webScrapingUtility
    }
    
    var message: String {
        switch self {
        case .javascriptError:
            return "Javascript error"
        case .failedToExecuteDetectTextScript:
            return "Failed to execute detect text script"
        case .failedToCastReturnValue:
            return "Failed to cast return value"
        case .failedToExecuteScrapingScript:
            return "Failed to execute scraping script"
        case .failedToExecuteLoginScript:
            return "Failed to execute login script"
        }
    }
}
