//
//  BinkHTTPHeaders.swift
//  binkapp
//
//  Created by Sean Williams on 23/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

struct BinkHTTPHeaders {
    public static let defaultHeaders: [BinkHTTPHeader] = [.defaultUserAgent, .defaultContentType]
}

struct BinkHTTPHeader {
    private let name: String
    private let value: String
    public static var headers: [BinkHTTPHeader] = []

    
    // MARK: - Headers

    public static func userAgent(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "User-Agent", value: value)
    }
    
    public static func contentType(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "Content-Type", value: value)
    }
    
    public static func acceptEncoding(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "Accept", value: value)
    }
    
    public static func authorization(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "Authorization", value: "Token \(value)")
    }
    
    
    // MARK: - Defaults

    public static let defaultUserAgent: BinkHTTPHeader = {
        return userAgent("Bink App / iOS \(Bundle.shortVersionNumber ?? "") / \(UIDevice.current.systemVersion)")
    }()
    
    public static let defaultContentType: BinkHTTPHeader = {
        return contentType("application/json")
    }()
    
    public static let defaultAcceptEncoding: BinkHTTPHeader = {
        return acceptEncoding("application/json")
//        return BinkHTTPHeader(name: "Accept", value: "application/json\(APIEndpoint.shouldVersionPin ? ";\(Current.apiClient.apiVersion.rawValue)" : "")")
    }()
    
    
    // MARK: - Convert To Dictionary

    public static func dictionary(headers: [BinkHTTPHeader]) -> [String: String] {
        let namesAndValues = headers.map { ($0.name, $0.value) }

        return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
    }
    
//    public static let defaultAuthorisation: BinkHTTPHeader = {
//        guard let token = Current.userManager.currentToken else { return headers }
//        return authorization(<#T##value: String##String#>)
//    }
    
    
    //        if authRequired {
    //            guard let token = Current.userManager.currentToken else { return headers }
    //            headers["Authorization"] = "Token " + token
    //        }
    
}
