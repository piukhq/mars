//
//  UniversalLinkUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 05/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation
import JWTDecode

class UniversalLinkUtility {
    enum LinkType: String {
        case magicLinkToken = "token"
    }
    
    private let loginController = LoginController()
    
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
        // Check token for expiry
        guard let decodedToken = try? decode(jwt: token), let tokenExpiry = decodedToken.body["exp"] as? TimeInterval else {
            loginController.handleMagicLinkFailed()
            return
        }
        guard Date().isBefore(date: Date(timeIntervalSince1970: tokenExpiry), toGranularity: .second) else {
            loginController.handleMagicLinkExpiredToken()
            return
        }
        loginController.exchangeMagicLinkToken(token: token) { [weak self] error in
            if let error = error {
                switch error {
                case .magicLinkExpired:
                    self?.loginController.handleMagicLinkExpiredToken()
                default:
                    self?.loginController.handleMagicLinkFailed()
                }
            }
        }
    }
}
