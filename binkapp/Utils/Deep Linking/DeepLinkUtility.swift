//
//  DeepLinkUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 05/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

enum DeepLinkUtility {
    enum DeepLinkType: String {
        case magicLink = "magic"
    }
    
    static func handleDeepLink(for url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        guard let host = urlComponents.host, let deepLinkType = DeepLinkType(rawValue: host) else { return }
        
        switch deepLinkType {
        case .magicLink:
            handleMagicLinkDeepLink(urlComponents: urlComponents)
        }
    }
    
    private static func handleMagicLinkDeepLink(urlComponents: URLComponents) {
        guard let queryItems = urlComponents.queryItems else { return }
        
        for item in queryItems {
            if item.name == "token" {
                // TODO: Use token to exchange for access token
            }
        }
    }
}
