//
//  UserManager.swift
//  binkapp
//
//  Created by Max Woodhams on 01/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import KeychainAccess
import FBSDKLoginKit

private enum UserManagerError: Error {
    case missingData
}

class UserManager {
    private struct Constants {
        static let tokenKey = "token_key"
        static let emailKey = "email_key"
    }
    
    private let keychain = Keychain(service: APIConstants.bundleID)
    
    lazy var currentToken: String? = getKeychainValue(for: Constants.tokenKey)
    lazy var currentEmailAddress: String? = getKeychainValue(for: Constants.emailKey)

    var hasCurrentUser: Bool {
        // We can safely assume that if we have no token, we have no user
        guard let token = currentToken else { return false }
        guard !token.isEmpty else { return false }
        return true
    }
    
    private func getKeychainValue(for key: String) -> String? {
        var token: String? = nil
        
        do {
            try token = keychain.getString(key)
        } catch let error {
            print(error)
        }
        
        return token
    }
        
    func setNewUser<T>(with response: T) where T: TokenResponseProtocol {
            do {
                try setToken(with: response)
                if let loginRegisterResponse = response as? LoginRegisterResponse {
                    try setEmail(with: loginRegisterResponse)
                }
            } catch let error {
                print(error)
            }
    }
    
    private func setToken(with response: TokenResponseProtocol) throws {
        guard let token = response.apiKey else { throw UserManagerError.missingData }
        try keychain.set(token, key: Constants.tokenKey)
        currentToken = token
    }
    
    private func setEmail(with response: LoginRegisterResponse) throws {
        guard let email = response.email else { throw UserManagerError.missingData }
        try keychain.set(email, key: Constants.emailKey)
        currentEmailAddress = email
    }
    
    func removeUser() {
        // Tidy up keychain
        try? keychain.remove(Constants.tokenKey)
        try? keychain.remove(Constants.emailKey)
        
        // Remove local variables
        currentToken = nil
        currentEmailAddress = nil
        
        // Logout of Facebook
        if AccessToken.current != nil {
            let loginManager = LoginManager()
            loginManager.logOut()
        }
    }
}
