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
        case addAuthRepository
        case walletService
        case loyaltyWalletViewModel
        case loyaltyCardFullDetailsViewModel
        case loyaltyCardFullDetailsRepository
        case loyaltyWalletRepository
    }
    
    enum Event: String {
        case paymentCardAdded = "Payment card added"
        case paymentCardDeleted = "Payment card deleted"
        case spreedlyTokenResponseSuccess = "Spreedly token success"
        case loyaltyCardAdded = "Loyalty card added"
        case ghostCardAdded = "Ghost card added"
        case loyaltyCardDeleted = "Loyalty card deleted"
    }
    
    enum Error: String {
        case addPaymentCardFailure = "Add payment card failure"
        case deletePaymentCardFailure = "Delete payment card failure"
        case spreedlyTokenResponseFailure = "Spreedly response failure"
        case addLoyaltyCardFailure = "Add loyalty card failure"
        case addGhostCardFailure = "Add ghost card failure"
        case deleteLoyaltyCardFailure = "Delete loyalty card failure"

    }
    
    // Debug - Not persisted: Not shown in exported logs
    
    static func debug(_ event: Event, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.debug("\(event.rawValue, privacy: .public) \(value ?? "", privacy: .public)")
    }
    
    
    // Info - Only recent logs persisted, written to disk
    
    static func info(_ event: Event, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.info("\(event.rawValue) \(value ?? "", privacy: .public)")
    }

    static func infoPrivate(_ event: Event, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.info("\(event.rawValue) \(value ?? "", privacy: .private)")
    }

    static func infoPrivateHash(_ event: Event, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.info("\(event.rawValue) \(value ?? "", privacy: .private(mask: .hash))")
    }


    // Log - For troubleshooting, written to memory and disk

    static func log(_ event: Event, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.log("\(event.rawValue, privacy: .public) \(value ?? "", privacy: .public)")
    }

    static func logPrivate(_ event: Event, value: String, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.log("\(event.rawValue) \(value, privacy: .private)")
    }

    static func logPrivateHash(_ event: Event, value: String, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.log("\(event.rawValue) \(value, privacy: .private(mask: .hash))")
    }


    // Error - Persisted to memory and disk

    static func error(_ message: Error, value: String?, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.error("\(message.rawValue, privacy: .public) \(value ?? "", privacy: .public)")
    }
    
    static func errorPrivate(_ message: Error, value: String, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.error("\(message.rawValue, privacy: .public) \(value, privacy: .private)")
    }
}
