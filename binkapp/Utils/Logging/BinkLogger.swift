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

    enum Category: String {
        case addPaymentCardViewModel
        case paymentWalletRepository
        case paymentWalletViewModel
        case paymentCardDetailViewModel
        case paymentCardDetailRepository
        case addAuthRepository
        case walletService
        case loyaltyWalletViewModel
        case loyaltyCardFullDetailsViewModel
        case loyaltyCardFullDetailsRepository
        case loyaltyWalletRepository
        case pllScreenRepository
        case database
        case barcodeScannerViewController
        case onboardingViewController
        case preferencesViewModel
        case settingsViewController
        case secureUtility
        case userManager
        case userServiceProtocol
    }
    
    enum Event: String {
        case paymentCardAdded = "Payment card added"
        case paymentCardDeleted = "Payment card deleted"
        case spreedlyTokenResponseSuccess = "Spreedly token success"
        case loyaltyCardAdded = "Loyalty card added"
        case ghostCardAdded = "Ghost card added"
        case ghostCardUpdated = "Ghost card updated"
        case loyaltyCardDeleted = "Loyalty card deleted"
        case pllLoyaltyCardLinked = "PLL loyalty card linked"
        case pllLoyaltyCardUnlinked = "PLL loyalty card unlinked"
        case databaseInitialised = "Database initialised at"
        case getMembershipPlans = "Got membership plans"
        case getPaymentCards = "Got payment cards"
        case getPaymentCard = "Got payment card"
        case getMembershipCards = "Got membership cards"
        case getUserProfile = "Got user profile"
    }
    
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
        case getKeychainValueFromKey = "Problem getting keychain value from key"
        case setNewUser = "Problem setting new user"
        case getMembershipPlans = "Problem getting membership plans"
        case getPaymentCards = "Problem getting payment cards"
        case getPaymentCard = "Problem getting payment card"
        case getMembershipCards = "Problem getting membership cards"
        case getUserProfile = "Failed to get user profile"
    }
    
    // Debug - Not persisted: Not shown in exported logs
    
    static func debug(_ event: Event, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.debug("\(event.rawValue, privacy: .public): \(value ?? "", privacy: .public)")
    }
    
    
    // Info - Only recent logs persisted, written to disk
    
    static func info(_ event: Event, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.info("\(event.rawValue): \(value ?? "", privacy: .public)")
    }

    static func infoPrivate(_ event: Event, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.info("\(event.rawValue): \(value ?? "", privacy: .private)")
    }

    static func infoPrivateHash(_ event: Event, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.info("\(event.rawValue): \(value ?? "", privacy: .private(mask: .hash))")
    }


    // Log - For troubleshooting, written to memory and disk

    static func log(_ event: Event, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.log("\(event.rawValue, privacy: .public): \(value ?? "", privacy: .public)")
    }

    static func logPrivate(_ event: Event, value: String, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.log("\(event.rawValue): \(value, privacy: .private)")
    }

    static func logPrivateHash(_ event: Event, value: String, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.log("\(event.rawValue): \(value, privacy: .private(mask: .hash))")
    }


    // Error - Persisted to memory and disk

    static func error(_ message: Error, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.error("\(message.rawValue, privacy: .public): \(value ?? "", privacy: .public)")
    }
    
    static func errorPrivate(_ message: Error, value: String, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.error("\(message.rawValue, privacy: .public): \(value, privacy: .private)")
    }
}
