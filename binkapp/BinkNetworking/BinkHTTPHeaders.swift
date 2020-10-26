//
//  BinkHTTPHeaders.swift
//  binkapp
//
//  Created by Sean Williams on 23/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

struct BinkHTTPHeaders {
    public let defaultHeaders: [BinkHTTPHeader] = [.defaultUserAgent, .defaultContentType]
}

struct BinkHTTPHeader {
    private let name: String
    private let value: String
    
    // MARK: - Headers

    public static func userAgent(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "User-Agent", value: value)
    }
    
    public static func contentType(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "Content-Type", value: value)
    }
    
    public static func acceptEncoding(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "Accect", value: value)
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
    
 
    
    
}
