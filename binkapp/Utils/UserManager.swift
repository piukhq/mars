//
//  UserManager.swift
//  binkapp
//
//  Created by Max Woodhams on 01/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import KeychainAccess
import Sentry
import Firebase
import WidgetKit

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
    private enum Constants {
        static let tokenKey = "token_key"
        static let emailKey = "email_key"
        static let firstNameKey = "first_name_key"
        static let lastNameKey = "last_name_key"
        static let userIdKey = "user_id_key"
    }
    
    private let keychain = Keychain(service: APIConstants.bundleID)
    
    lazy var currentToken: String? = getKeychainValue(for: Constants.tokenKey)
    lazy var currentEmailAddress: String? = getKeychainValue(for: Constants.emailKey)
    lazy var currentFirstName: String? = getKeychainValue(for: Constants.firstNameKey)
    lazy var currentLastName: String? = getKeychainValue(for: Constants.lastNameKey)
    lazy var currentUserId: String? = getKeychainValue(for: Constants.userIdKey)
    
    var hasCurrentUser: Bool {
        // We can safely assume that if we have no token, we have no user
        guard let token = currentToken, !token.isEmpty else {
            UserDefaults(suiteName: WidgetType.quickLaunch.userDefaultsSuiteID)?.set(false, forDefaultsKey: .hasCurrentUser)
            Current.watchController.hasCurrentUser(false)
            return false
        }
        
        // Store in shared container
        UserDefaults(suiteName: WidgetType.quickLaunch.userDefaultsSuiteID)?.set(true, forDefaultsKey: .hasCurrentUser)
        return true
    }
    
    private func getKeychainValue(for key: String) -> String? {
        var token: String?
        
        do {
            try token = keychain.getString(key)
        } catch {
            BinkLogger.error(AppLoggerError.retrieveKeychainValueFromKey, value: error.localizedDescription)
        }
        
        return token
    }
    
    func setNewUser(with response: LoginResponse) {
        do {
            try setToken(with: response)
            try setEmail(with: response)
            UserDefaults(suiteName: WidgetType.quickLaunch.userDefaultsSuiteID)?.set(true, forDefaultsKey: .hasCurrentUser)
        } catch {
            BinkLogger.error(UserLoggerError.setNewUser, value: error.localizedDescription)
        }
    }
    
    func setProfile(withResponse response: UserProfileResponse) {
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
        if let userId = response.uid {
            try? keychain.set(userId, key: Constants.userIdKey)
            currentUserId = userId
            let sentryUser = Sentry.User(userId: userId)
            SentrySDK.setUser(sentryUser)
            Analytics.setUserID(userId)
            
            MixpanelUtility.setUserIdentity(userId: userId)
        }

        PreferencesViewModel().configureUserPreferenceFromAPI()
    }
    
    private func setToken(with response: LoginResponse) throws {
        guard let token = response.jwt else { throw UserManagerError.missingData }
        try keychain.set(token, key: Constants.tokenKey)
        currentToken = token
    }
    
    private func setEmail(with response: LoginResponse) throws {
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
        try? AutofillUtil.clearKeychain()
        
        // Remove local variables
        currentToken = nil
        currentEmailAddress = nil
        currentFirstName = nil
        currentLastName = nil
        
        UserDefaults(suiteName: WidgetType.quickLaunch.userDefaultsSuiteID)?.set(false, forDefaultsKey: .hasCurrentUser)
        WidgetController().reloadWidget(type: .quickLaunch)
        Current.watchController.hasCurrentUser(false)
    }
    
    func clearKeychainIfNecessary() {
        if !Current.userDefaults.bool(forDefaultsKey: .hasPreviouslyLaunchedApp) {
            for key in keychain.allKeys() {
                if key != Constants.tokenKey {
                    do {
                        try keychain.remove(key)
                    } catch {
                        fatalError("Could not remove item from keychain on first launch: \(error)")
                    }
                }
            }
            Current.userDefaults.set(true, forDefaultsKey: .hasPreviouslyLaunchedApp)
        }
    }
}
