//
//  BinkHTTPHeaders.swift
//  binkapp
//
//  Created by Sean Williams on 23/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

struct BinkHTTPHeaders {
    public let defaultHeaders: [BinkHTTPHeader] = [.userAgent]
}

struct BinkHTTPHeader {
    private let name: String
    private let value: String
    
    public static let userAgent: BinkHTTPHeader = {
        return BinkHTTPHeader(name: "User-Agent", value: "Bink App / iOS \(Bundle.shortVersionNumber ?? "") / \(UIDevice.current.systemVersion)")
    }()
    
    public static let contentType: BinkHTTPHeader = {
        return BinkHTTPHeader(name: "Content-Type", value: "application/json")
    }()
    
    public static let accept: BinkHTTPHeader = {
        return BinkHTTPHeader(name: "Accept", value: "application/json\(APIEndpoint.shouldVersionPin ? ";\(Current.apiClient.apiVersion.rawValue)" : "")")
    }()
    
 
    
    
}
