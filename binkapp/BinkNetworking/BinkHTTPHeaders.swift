//
//  BinkHTTPHeaders.swift
//  binkapp
//
//  Created by Sean Williams on 23/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

struct BinkHTTPHeaders {
    static func dictionary(_ headers: [BinkHTTPHeader]) -> [String: String] {
        let namesAndValues = headers.map { ($0.name, $0.value) }
        return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
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
    
    static let acceptWithAPIVersion: BinkHTTPHeader = {
        return accept("application/json;\(Current.apiClient.apiVersion.rawValue)")
    }()
    
    
    // MARK: - Convert To Dictionary

    static func dictionary(_ headers: [BinkHTTPHeader]) -> [String: String] {
        let namesAndValues = headers.map { ($0.name, $0.value) }
        return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
    }
}
