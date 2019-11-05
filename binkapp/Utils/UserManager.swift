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

class UserManager {
    private struct Constants {
        static let tokenKey = "token"
        static let passwordKey = "password"
    }
    
    private let keychain = Keychain(service: APIConstants.bundleID)
        
    func setNewUser<T>(with response: T) where T: TokenResponseProtocol {
        if let token = response.apiKey {
            do {
                try keychain.set(token, key: Constants.tokenKey)
            } catch let error {
                print(error)
            }
        }
    }
    
    func removeUser() {
        try? keychain.remove(Constants.tokenKey)
        
        // Logout of Facebook
        if AccessToken.current != nil {
            let loginManager = LoginManager()
            loginManager.logOut()
        }
    }
    
    func currentToken() -> String? {
        var token: String? = nil
        
        do {
            try token = keychain.get(Constants.tokenKey)
        } catch let error {
            print(error)
        }
        
        return token
    }
}
