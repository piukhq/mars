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
import FirebaseCrashlytics

private enum UserManagerError: Error {
    case missingData
}

struct UserProfileResponse: Codable {
    var uid: String?
    var firstName: String?
    var lastName: String?
    var email: String?

    enum CodingKeys: String, CodingKey {
        case uid
        case firstName = "first_name"
        case lastName = "last_name"
        case email
    }
}

struct UserProfileUpdateRequest: Codable {
    var firstName: String?
    var lastName: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

class UserManager {
    private struct Constants {
        static let tokenKey = "token_key"
        static let emailKey = "email_key"
        static let firstNameKey = "first_name_key"
        static let lastNameKey = "last_name_key"
    }
    
    private let keychain = Keychain(service: APIConstants.bundleID)
    
    lazy var currentToken: String? = getKeychainValue(for: Constants.tokenKey)
    lazy var currentEmailAddress: String? = getKeychainValue(for: Constants.emailKey)
    lazy var currentFirstName: String? = getKeychainValue(for: Constants.firstNameKey)
    lazy var currentLastName: String? = getKeychainValue(for: Constants.lastNameKey)

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

    func setProfile(withResponse response: UserProfileResponse, updateZendeskIdentity: Bool)  {
        // Store what we can, but don't bail if the values don't exist
        if let email = response.email {
            try? keychain.set(email, key: Constants.emailKey)
            currentEmailAddress = email
        }
        if let firstName = response.firstName {
            try? keychain.set(firstName, key: Constants.firstNameKey)
            currentFirstName = firstName
        }
        if let lastName = response.lastName {
            try? keychain.set(lastName, key: Constants.lastNameKey)
            currentLastName = lastName
        }

        if updateZendeskIdentity {
            ZendeskService.setIdentity(firstName: currentFirstName, lastName: currentLastName)
        }
        
        // Set user id for Crashlytics
        guard let userId = response.uid else { return }
        Crashlytics.crashlytics().setUserID(userId)
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
        try? keychain.remove(Constants.firstNameKey)
        try? keychain.remove(Constants.lastNameKey)
        
        // Remove local variables
        currentToken = nil
        currentEmailAddress = nil
        currentFirstName = nil
        currentLastName = nil
        
        // Logout of Facebook
        if AccessToken.current != nil {
            let loginManager = LoginManager()
            loginManager.logOut()
        }
    }
}
