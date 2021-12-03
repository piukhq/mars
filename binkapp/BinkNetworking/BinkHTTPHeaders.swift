//
//  BinkHTTPHeaders.swift
//  binkapp
//
//  Created by Sean Williams on 23/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

enum BinkHTTPHeaders {
    static func asDictionary(_ headers: [BinkHTTPHeader]) -> [String: String] {
        var dictionary: [String: String] = [:]
        headers.forEach {
            dictionary[$0.name] = $0.value
        }
        return dictionary
    }
}

struct BinkHTTPHeader {
    let name: String
    let value: String
    
    // MARK: - Headers

    static func userAgent(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "User-Agent", value: value)
    }
    
    static func contentType(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "Content-Type", value: value)
    }
    
    static func accept(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "Accept", value: value)
    }
    
    static func authorization(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "Authorization", value: "Token \(value)")
    }
    
    static func binkTestAuth() -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "Bink-Test-Auth", value: "e66cd653a8a1a4ee49ef7b4f2f44517e01e4e513c0c0ad4cc0818696847f98be")
    }
    
    // MARK: - Defaults

    static let defaultUserAgent: BinkHTTPHeader = {
        return userAgent("Bink App / iOS \(Bundle.shortVersionNumber ?? "") / \(UIDevice.current.systemVersion)")
    }()
    
    static let defaultContentType: BinkHTTPHeader = {
        return contentType("application/json")
    }()
    
    static let defaultAccept: BinkHTTPHeader = {
        return accept("application/json")
    }()
    
    static func acceptWithAPIVersion() -> BinkHTTPHeader {
        let apiVersion: String
        
        #if DEBUG
        apiVersion = Current.apiClient.overrideVersion?.rawValue ?? Current.apiClient.apiVersion.rawValue
        #else
        apiVersion = Current.apiClient.apiVersion.rawValue
        #endif
        
        return accept("application/json;\(apiVersion)")
    }
}
