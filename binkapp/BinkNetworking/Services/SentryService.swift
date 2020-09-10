//
//  SentryService.swift
//  binkapp
//
//  Created by Max Woodhams on 09/09/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import Sentry

final class SentryService {
    
    private static let prodBundleIdentifier = "com.bink.wallet"
    
    private static var environment: String {
        let envString: String

        if isReleaseTypeBuild && APIConstants.isProduction && !isDebug {
            envString = "prod"
        } else {
            envString = "beta"
        }
        
        return envString
    }
    
    private static var isReleaseTypeBuild: Bool {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            // I can't imagine a scenario where this would be not set?
            return false
        }
        
        return bundleIdentifier == prodBundleIdentifier
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
}
