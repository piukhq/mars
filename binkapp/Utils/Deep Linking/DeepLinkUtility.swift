//
//  DeepLinkUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 05/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

class DeepLinkUtility {
    enum DeepLinkType: String {
        case magicLink = "magic"
    }
    
    private let loginController = LoginController()
    
    func handleDeepLink(for url: URL, completion: @escaping (Bool) -> Void) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        guard let host = urlComponents.host, let deepLinkType = DeepLinkType(rawValue: host) else { return }
        
        switch deepLinkType {
        case .magicLink:
            handleMagicLinkDeepLink(urlComponents: urlComponents, completion: completion)
        }
    }
    
    private func handleMagicLinkDeepLink(urlComponents: URLComponents, completion: @escaping (Bool) -> Void) {
        guard let queryItems = urlComponents.queryItems else { return }
        
        for item in queryItems {
            if item.name == "token", let token = item.value {
                loginController.exchangeMagicLinkToken(token: token, completion: completion)
            }
        }
    }
}
