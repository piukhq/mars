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
    
    static func info<E: BinkLoggerProtocol>(_ event: E, value: String? = nil, file: NSString? = #file) {
            let logger = Logger(subsystem: subsystem, category: "\(event.category.rawValue) - \(file?.lastPathComponent ?? "")")
            logger.info("\(event.message)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .public)")
        }


//    static func infoPrivate(_ event: Event, value: String? = nil, category: Category) {
//        let logger = Logger(subsystem: subsystem, category: category.rawValue)
//        logger.info("\(event.rawValue)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .private)")
//    }

    static func infoPrivateHash<E: BinkLoggerProtocol>(_ event: E, value: String? = nil, file: NSString? = #file) {
        let logger = Logger(subsystem: subsystem, category: "\(event.category.rawValue) - \(file?.lastPathComponent ?? "")")
        logger.info("\(event.message)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .private(mask: .hash))")
    }


    // Log - For troubleshooting, written to memory and disk

    static func log<E: BinkLoggerProtocol>(_ event: E, value: String? = nil, file: NSString? = #file) {
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

    static func error<E: BinkLoggerProtocol>(_ error: E, value: String? = nil, file: NSString? = #file) {
        let logger = Logger(subsystem: subsystem, category: "\(error.category.rawValue) - \(file?.lastPathComponent ?? "")")
        logger.error("\(error.message, privacy: .public)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .public)")
    }
    
    static func errorPrivate<E: BinkLoggerProtocol>(_ error: E, value: String, file: NSString? = #file) {
        let logger = Logger(subsystem: subsystem, category: "\(error.category.rawValue) - \(file?.lastPathComponent ?? "")")
        logger.error("\(error.message, privacy: .public): \(value, privacy: .private)")
    }
}
