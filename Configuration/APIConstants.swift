//
//  APIConstants.swift
//  binkapp
//
//  Created by Max Woodhams on 10/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }
    
    static func value(for key: String) throws -> String {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else { throw Error.missingKey }
        guard let string = object as? String, !string.isEmpty else { throw Error.invalidValue }
        return string
    }
}

enum APIConstants {
    static let productionBaseURL = "https://api.staging.gb.bink.com"

    static var baseURLString: String {
        do {
            let configURL = try Configuration.value(for: "API_BASE_URL")
            return "https://" + configURL
        }
        catch {
            fatalError(error.localizedDescription)
        }
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
}
