//
//  UniversalLinkUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 05/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

class UniversalLinkUtility {
    enum LinkType: String {
        case magicLinkToken = "token"
    }
    
    func handleLink(for url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        guard let queryItems = urlComponents.queryItems else { return }
        
        for item in queryItems {
            guard let linkType = LinkType(rawValue: item.name) else { return }
            guard let value = item.value else { return }
            switch linkType {
            case .magicLinkToken:
                handleMagicLink(token: value)
            }
        }
    }
    
    private func handleMagicLink(token: String) {
        // Check if we have current user
        let currentEmail = Current.userManager.currentEmailAddress ?? ""
        
        // If current email address matches email from token - return
        let decodedEmail = Current.loginController.decodedEmailAddress(from: token) ?? ""
        
        guard currentEmail != decodedEmail else {
            
            return
        }
        
        // If its a different email address, present alert - if OK is tapped, logout and exchange magic link token
        
        Current.loginController.exchangeMagicLinkToken(token: token, withPreferences: [:]) { error in
            if let error = error {
                switch error {
                case .magicLinkExpired:
                    Current.loginController.handleMagicLinkExpiredToken(token: token)
                default:
                    Current.loginController.handleMagicLinkFailed(token: token)
                }
            }
        }
    }
}
