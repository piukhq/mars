//
//  SentryService.swift
//  binkapp
//
//  Created by Max Woodhams on 09/09/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import Sentry

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
//        SentrySDK.capture(error: exception.formattedError) { scope in
//            scope.setTag(value: exception.userJourneyTagValue, key: "user_journey")
//        }
    }
}

enum SentryException {
    enum Domain: String {
        case general = "Bink Native General Errors"
        case loyalty = "Bink Native Loyalty Card Onboard Issues"
        case payment = "Bink Native Payment Card Enrol Issues"
        case lpc = "Local Points Scraping Issues"

        var identifier: String {
            switch self {
            case .general:
                return "BNE1"
            case .loyalty:
                return "BNE2"
            case .payment:
                return "BNE3"
            case .lpc:
                return "BNE4"
            }
        }

        var userJourney: String {
            switch self {
            case .payment:
                return "add_payment_card"
            case .loyalty:
                return "add_loyalty_card"
            case .lpc:
                return "local_points_collection"
            default:
                return ""
            }
        }
    }

    enum InvalidPayloadReason: String {
        case failedToEncryptFirstSix = "Failed to encrypt first six"
        case failedToEncryptLastFour = "Failed to encrypt last four"
        case failedToEncryptMonth = "Failed to encrypt expiry month"
        case failedToEncryptYear = "Failed to encrypt expiry year"
    }

    case invalidPayload(InvalidPayloadReason)
    case tokenisationServiceRejectedRequest(NetworkResponseData?)
    case apiRejectedRequest(NetworkResponseData?)
    case localPointsCollectionFailed(WebScrapingUtilityError, WebScrapableMerchant, balanceRefresh: Bool)

    var formattedError: NSError {
        return NSError(domain: domain.rawValue, code: errorCode, userInfo: userInfo)
    }

    var userJourneyTagValue: String {
        return domain.userJourney
    }

    var errorCode: Int {
        switch self {
        case .invalidPayload:
            return 3000
        case .tokenisationServiceRejectedRequest:
            return 3001
        case .apiRejectedRequest:
            return 3002
        case .localPointsCollectionFailed(let error, _, _):
            switch error.level {
            case .client:
                return 4001
            case .site:
                return 4002
            case .user:
                return 4003
            }
        }
    }

    private var domain: Domain {
        switch self {
        case .invalidPayload, .tokenisationServiceRejectedRequest, .apiRejectedRequest:
            return .payment
        case .localPointsCollectionFailed:
            return .lpc
        }
    }

    private var userInfo: [String: Any] {
        var info: [String: Any] = [NSLocalizedDescriptionKey: localizedDescription]
        switch self {
        case .invalidPayload(let reason):
            info["reason"] = reason.rawValue
            return info
        case .tokenisationServiceRejectedRequest(let networkResponse), .apiRejectedRequest(let networkResponse):
            guard let response = networkResponse else { return info }
            info["network_response"] = response
            return info
        case .localPointsCollectionFailed(let error, let merchant, let isBalanceRefresh):
            return [
                "error_message": error.localizedDescription,
                "merchant": merchant.rawValue,
                "balance_refresh": isBalanceRefresh
            ]
        }
    }

    private var localizedDescription: String {
        switch self {
        case .invalidPayload:
            return "Could not construct payload for tokenisation"
        case .tokenisationServiceRejectedRequest:
            return "Tokenisation service rejected request"
        case .apiRejectedRequest:
            return "Bink API rejected request"
        case .localPointsCollectionFailed:
            return "Local points collection failed"
        }
    }
}
