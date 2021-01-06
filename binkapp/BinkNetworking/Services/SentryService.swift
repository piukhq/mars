//
//  SentryService.swift
//  binkapp
//
//  Created by Max Woodhams on 09/09/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import Sentry

enum SentryException: Int {
    enum Domain: String {
        case general = "Bink Native General Errors"
        case loyalty = "Bink Native Loyalty Card Onboard Issues"
        case payment = "Bink Native Payment Card Enrol Issues"

        var codePrefix: String {
            switch self {
            case .general:
                return "BNE1"
            case .loyalty:
                return "BNE2"
            case .payment:
                return "BNE3"
            }
        }

        var userJourney: String {
            switch self {
            case .payment:
                return "add_payment_card"
            default:
                return ""
            }
        }
    }

    case invalidPayload = 3000
    case tokenisationServiceRejectedRequest = 3001
    case apiRejectedRequest = 3002

    var formattedError: NSError {
        return NSError(domain: domain.rawValue, code: rawValue, userInfo: userInfo)
    }

    var userJourneyTagValue: String {
        return domain.userJourney
    }

    private var domain: Domain {
        switch self {
        case .invalidPayload, .tokenisationServiceRejectedRequest, .apiRejectedRequest:
            return .payment
        }
    }

    private var userInfo: [String: Any] {
        return [
            NSLocalizedDescriptionKey: localizedDescription,
            "test": "icles"
        ]
    }

    private var localizedDescription: String {
        switch self {
        case .invalidPayload:
            return "Could not construct payload for tokenisation"
        case .tokenisationServiceRejectedRequest:
            return "Tokenisation service rejected request"
        case .apiRejectedRequest:
            return "Bink API rejected request"
        }
    }
}

enum SentryService {
    private static var environment: String {
        let envString: String

        if Current.isReleaseTypeBuild && APIConstants.isProduction && !isDebug {
            envString = "prod"
        } else {
            envString = "beta"
        }
        
        return envString
    }

    private static var isDebug: Bool {
        let isDebug: Bool
        #if DEBUG
            isDebug = true
        #else
            isDebug = false
        #endif
        
        return isDebug
    }
    
    static func start() {
        SentrySDK.start(options: [
            "dsn": "https://de94701e62374e53bef78de0317b8089@sentry.uksouth.bink.sh/20",
            "debug": isDebug, // Enabled debug when first installing is always helpful
            "environment": environment, // beta, or prod
            "release": Bundle.shortVersionNumber ?? ""
        ])
    }
    
    static func forceCrash() {
        SentrySDK.crash()
    }

    static func triggerException(_ exception: SentryException) {
        SentrySDK.capture(error: exception.formattedError) { scope in
            scope.setTag(value: "user_journey", key: exception.userJourneyTagValue)
        }
    }
}
