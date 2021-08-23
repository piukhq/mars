//
//  APIConstants.swift
//  binkapp
//
//  Created by Max Woodhams on 10/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

private var debugBaseURL = "" {
    didSet {
        Current.userDefaults.set(debugBaseURL, forDefaultsKey: .debugBaseURL)
    }
}

enum EnvironmentType: String, CaseIterable {
    case dev = "api.dev.gb.bink.com"
    case staging = "api.staging.gb.bink.com"
    case preprod = "api.preprod.gb.bink.com"
    case production = "api.gb.bink.com"
}

enum Configuration {
    enum ConfigurationError: BinkError {
        case missingKey
        case invalidValue

        var domain: BinkErrorDomain {
            return .configuration
        }

        var message: String {
            switch self {
            case .missingKey:
                return "Missing key"
            case .invalidValue:
                return "Invalid value"
            }
        }
    }
    
    enum ConfigurationKey: String {
        case apiBaseUrl = "API_BASE_URL"
        case secret = "SECRET"
        case debugMenu = "DEBUG_MENU"
    }
    
    static func value(for key: ConfigurationKey) throws -> String {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key.rawValue) else { throw ConfigurationError.missingKey }
        guard let string = object as? String, !string.isEmpty else { throw ConfigurationError.invalidValue }
        return string
    }
    
    static func isDebug() -> Bool {
        if let _ = try? value(for: .debugMenu) {
            return true
        }
        return false
    }
}

enum APIConstants {
    static var currentEnvironment: EnvironmentType {
        guard let environmment = EnvironmentType(rawValue: baseURLString) else {
            fatalError("Could not identify environment")
        }
        return environmment
    }
    
    static var isProduction: Bool {
        return baseURLString == EnvironmentType.production.rawValue
    }
    
    static var isPreProduction: Bool {
        return baseURLString == EnvironmentType.preprod.rawValue
    }

    static var baseURLString: String {
        if let _ = try? Configuration.value(for: .debugMenu) {
            // If we have set the environment from the debug menu
            if let debugBaseURLString = Current.userDefaults.value(forDefaultsKey: .debugBaseURL) as? String {
                return debugBaseURLString
            }
        }

        do {
            let configBaseURL = try Configuration.value(for: .apiBaseUrl)
            return configBaseURL
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func changeEnvironment(environment: EnvironmentType) {
        debugBaseURL = environment.rawValue
    }
    
    static func moveToCustomURL(url: String) {
        if url.isEmpty {
            changeEnvironment(environment: .dev)
            return
        }
        debugBaseURL = url
    }
    
    enum SecretKeyType: String {
        case dev
        case staging
    }
    
    static var secretKeyType: SecretKeyType? {
        do {
            let rawValue = try Configuration.value(for: .secret)
            return SecretKeyType(rawValue: rawValue)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static let clientID = "MKd3FfDGBi1CIUQwtahmPap64lneCa2R6GvVWKg6dNg4w9Jnpd"
    static let bundleID = "com.bink.wallet"

    static func makeServicePostRequest(email: String) -> [String: [String: Any]] {
        return [
            "consent":
                [
                    "email": email,
                    "timestamp": Int(Date().timeIntervalSince1970)
                ]
        ]
    }
}
