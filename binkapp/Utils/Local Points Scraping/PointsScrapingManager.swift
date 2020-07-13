//
//  PointsScrapingManager.swift
//  binkapp
//
//  Created by Nick Farrant on 13/07/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import KeychainAccess

class PointsScrapingManager {
    enum CredentialStoreType: String {
        case username
        case password
    }
    
    enum PointsScrapingManagerError: BinkError {
        case failedToStoreCredentials
        case failedToRetrieveCredentials
        
        var domain: BinkErrorDomain {
            return .pointsScrapingManager
        }
        
        var message: String {
            return "An error occurred when retrieving your points balance."
        }
    }
    
    private static let baseCredentialStoreKey = "com.bink.wallet.pointsScraping.credentials.cardId_%@.%@"
    private let keychain = Keychain(service: APIConstants.bundleID)
    
    func storeCredentials(_ credentials: WebScrapingCredentials, forMembershipCardId cardId: String) throws {
        do {
            try keychain.set(credentials.username, key: keychainKeyForCardId(cardId, credentialType: .username))
            try keychain.set(credentials.password, key: keychainKeyForCardId(cardId, credentialType: .password))
        } catch {
            throw PointsScrapingManagerError.failedToStoreCredentials
        }
    }
    
    func retrieveCredentials(forMemebershipCardId cardId: String) throws -> WebScrapingCredentials {
        do {
            guard let username = try keychain.get(keychainKeyForCardId(cardId, credentialType: .username)),
                let password = try keychain.get(keychainKeyForCardId(cardId, credentialType: .password)) else {
                    throw PointsScrapingManagerError.failedToRetrieveCredentials
            }
            return WebScrapingCredentials(username: username, password: password)
        } catch {
            throw PointsScrapingManagerError.failedToRetrieveCredentials
        }
    }
    
    func removeCredentials(forMembershipCardId cardId: String) {
        try? keychain.remove(keychainKeyForCardId(cardId, credentialType: .username))
        try? keychain.remove(keychainKeyForCardId(cardId, credentialType: .password))
    }
    
    private func keychainKeyForCardId(_ cardId: String, credentialType: CredentialStoreType) -> String {
        return String(format: PointsScrapingManager.baseCredentialStoreKey, cardId, credentialType.rawValue)
    }
}
