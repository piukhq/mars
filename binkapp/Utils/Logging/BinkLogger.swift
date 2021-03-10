//
//  BinkLogger.swift
//  binkapp
//
//  Created by Sean Williams on 04/03/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation
import os

@available(iOS 14.0, *)
enum BinkLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? ""
    
    enum Error: String {
        case addPaymentCardFailure = "Add payment card failure"
        case deletePaymentCardFailure = "Delete payment card failure"
        case spreedlyTokenResponseFailure = "Spreedly response failure"
        case addLoyaltyCardFailure = "Add loyalty card failure"
        case addGhostCardFailure = "Add ghost card failure"
        case updateGhostCardFailure = "Update ghost card failure"
        case deleteLoyaltyCardFailure = "Delete loyalty card failure"
        case pllLoyaltyCardLinkingFailure = "PLL loyalty card linking failure"
        case pllLoyaltyCardUnlinkingFailure = "PLL loyalty card unlinking failure"
        case coreDataObjectMappingFailure = "Could not map object"
        case lockDeviceForAVCaptureConfig = "Could not aquire device lock for AV capture configuration"
        case appleSignIn = "Apple sign in auth failure"
        case updatePreferences = "Preferences update failure"
        case unsupportedViewController = "Unsupported view controller for presentation"
        case stringEncryption = "Sensitive field string encryption failure"
        case retrieveKeychainValueFromKey = "Problem fetching keychain value from key"
        case setNewUser = "Problem setting new user"
        case fetchMembershipPlans = "Problem fetching membership plans"
        case fetchPaymentCards = "Problem fetching payment cards"
        case fetchPaymentCard = "Problem fetching payment card"
        case fetchMembershipCards = "Problem fetching membership cards"
        case fetchUserProfile = "Failed to fetch user profile"
        case updateUserProfileFailure = "Failed to update user profile"
        case userLogoutFailure = "Failed to log user out"
        case forgotPasswordRequestFailure = "Forgot password request submission failure"
        case userRegistrationFailure = "Failed to register user"
        case userLoginFailure = "Failed to login"
        case facebookAuthFailure = "Failed to authorise user with Facebook"
        case createServiceFailure = "Failed to create service"
        case fetchPreferencesFailure = "Failed to fetch preferences"
        case setPreferencesFailure = "Failed to set preferences"
        case renewTokenFailure = "Failed to renew token"
        case remoteConfigFetchFailure = "Failed to fetch remote config data"
        case pointsScrapingFailure = "Failed points scraping"
        case barcodeScanningFailure = "Incorrect barcode scanned"
    }
    
    // Debug - Not persisted: Not shown in exported logs
    
//    static func debug(_ event: Event, value: String? = nil, category: Category) {
//        let logger = Logger(subsystem: subsystem, category: category.rawValue)
//        logger.debug("\(event.rawValue, privacy: .public)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .public)")
//    }
    
    
    // Info - Only recent logs persisted, written to disk
    
//    static func info(_ event: BinkLoggerEvent, value: String? = nil) {
//        let logger = Logger(subsystem: subsystem, category: event.category.rawValue)
//        logger.info("\(event.message)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .public)")
//    }
    
    static func info<E: BinkLoggerEvent>(_ event: E, value: String? = nil, file: NSString? = #file) {
            let logger = Logger(subsystem: subsystem, category: "\(event.category.rawValue) - \(file?.lastPathComponent ?? "")")
            logger.info("\(event.message)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .public)")
        }


//    static func infoPrivate(_ event: Event, value: String? = nil, category: Category) {
//        let logger = Logger(subsystem: subsystem, category: category.rawValue)
//        logger.info("\(event.rawValue)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .private)")
//    }

    static func infoPrivateHash<E: BinkLoggerEvent>(_ event: E, value: String? = nil, file: NSString? = #file) {
        let logger = Logger(subsystem: subsystem, category: "\(event.category.rawValue) - \(file?.lastPathComponent ?? "")")
        logger.info("\(event.message)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .private(mask: .hash))")
    }


    // Log - For troubleshooting, written to memory and disk

    static func log<E: BinkLoggerEvent>(_ event: E, value: String? = nil, file: NSString? = #file) {
        let logger = Logger(subsystem: subsystem, category: "\(event.category.rawValue) - \(file?.lastPathComponent ?? "")")
        logger.log("\(event.message, privacy: .public)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .public)")
    }

//    static func logPrivate(_ event: Event, value: String, category: Category) {
//        let logger = Logger(subsystem: subsystem, category: category.rawValue)
//        logger.log("\(event.rawValue) \(value, privacy: .private)")
//    }
//
//    static func logPrivateHash(_ event: Event, value: String, category: Category) {
//        let logger = Logger(subsystem: subsystem, category: category.rawValue)
//        logger.log("\(event.rawValue): \(value, privacy: .private(mask: .hash))")
//    }


    // Error - Persisted to memory and disk

    static func error(_ message: Error, value: String? = nil, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.error("\(message.rawValue, privacy: .public)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .public)")
    }
    
    static func errorPrivate(_ message: Error, value: String, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.error("\(message.rawValue, privacy: .public): \(value, privacy: .private)")
    }
}
