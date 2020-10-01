//
//  APIConstants.swift
//  binkapp
//
//  Created by Max Woodhams on 10/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

fileprivate var debugBaseURL = "" {
    didSet {
        Current.userDefaults.set(debugBaseURL, forDefaultsKey: .debugBaseURL)
    }
}

enum EnvironmentType: String {
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
    
    static func value(for key: String) throws -> String {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else { throw ConfigurationError.missingKey }
        guard let string = object as? String, !string.isEmpty else { throw ConfigurationError.invalidValue }
        return string
    }
}

struct APIConstants {
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
        #if DEBUG
        // If we have set the environment from the debug menu
        if let debugBaseURLString = Current.userDefaults.value(forDefaultsKey: .debugBaseURL) as? String {
            return debugBaseURLString
        }
        #endif


        do {
            let configBaseURL = try Configuration.value(for: "API_BASE_URL")
            return configBaseURL
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func changeEnvironment(environment: EnvironmentType) {
        debugBaseURL = environment.rawValue
    }
    
    static func moveToCustomURL(url: String) {
        if url == "" {
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
            let rawValue = try Configuration.value(for: "SECRET")
            return SecretKeyType(rawValue: rawValue)
        }
        catch {
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
