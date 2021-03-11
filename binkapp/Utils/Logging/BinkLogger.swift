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
    
    static func debug<E: BinkLoggerProtocol>(_ event: E, value: String? = nil, file: NSString? = #file) {
        let logger = Logger(subsystem: subsystem, category: "\(event.category.rawValue) - \(file?.lastPathComponent ?? "")")
        logger.debug("\(event.message, privacy: .public)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .public)")
    }
    
    
    // Info - Only recent logs persisted, written to disk
    
    static func info<E: BinkLoggerProtocol>(event: E, value: String? = nil, file: NSString? = #file) {
        let logger = Logger(subsystem: subsystem, category: "\(event.category.rawValue) - \(file?.lastPathComponent ?? "")")
        logger.info("\(event.message)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .public)")
    }
    
    static func infoPrivate<E: BinkLoggerProtocol>(_ event: E, value: String? = nil, file: NSString? = #file) {
        let logger = Logger(subsystem: subsystem, category: "\(event.category.rawValue) - \(file?.lastPathComponent ?? "")")
        logger.info("\(event.message)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .private)")
    }

    static func infoPrivateHash<E: BinkLoggerProtocol>(event: E, value: String? = nil, file: NSString? = #file) {
        let logger = Logger(subsystem: subsystem, category: "\(event.category.rawValue) - \(file?.lastPathComponent ?? "")")
        logger.info("\(event.message)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .private(mask: .hash))")
    }


    // Log - For troubleshooting, written to memory and disk

    static func log<E: BinkLoggerProtocol>(_ event: E, value: String? = nil, file: NSString? = #file) {
        let logger = Logger(subsystem: subsystem, category: "\(event.category.rawValue) - \(file?.lastPathComponent ?? "")")
        logger.log("\(event.message, privacy: .public)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .public)")
    }

    static func logPrivate<E: BinkLoggerProtocol>(_ event: E, value: String? = nil, file: NSString? = #file) {
        let logger = Logger(subsystem: subsystem, category: "\(event.category.rawValue) - \(file?.lastPathComponent ?? "")")
        logger.log("\(event.message)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .private)")
    }

    static func logPrivateHash<E: BinkLoggerProtocol>(_ event: E, value: String? = nil, file: NSString? = #file) {
        let logger = Logger(subsystem: subsystem, category: "\(event.category.rawValue) - \(file?.lastPathComponent ?? "")")
        logger.log("\(event.message)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .private(mask: .hash))")
    }


    // Error - Persisted to memory and disk

    static func error<E: BinkLoggerProtocol>(_ error: E, value: String? = nil, file: NSString? = #file) {
        let logger = Logger(subsystem: subsystem, category: "\(error.category.rawValue) - \(file?.lastPathComponent ?? "")")
        logger.error("\(error.message, privacy: .public)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .public)")
    }
    
    static func errorPrivate<E: BinkLoggerProtocol>(_ error: E, value: String? = nil, file: NSString? = #file) {
        let logger = Logger(subsystem: subsystem, category: "\(error.category.rawValue) - \(file?.lastPathComponent ?? "")")
        logger.error("\(error.message, privacy: .public)\(value == nil ? "" : ":", privacy: .public) \(value ?? "", privacy: .private)")
    }
}
