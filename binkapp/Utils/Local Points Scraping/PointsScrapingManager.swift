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
    
    // MARK: - Objects
    
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
    
    struct ScrapedBalance {
        var membershipCardId: String
        var pointsBalance: String
    }
    
    // MARK: - Properties
    
    private static let baseCredentialStoreKey = "com.bink.wallet.pointsScraping.credentials.cardId_%@.%@"
    private let keychain = Keychain(service: APIConstants.bundleID)
    
    private let agents: [WebScrapable] = [
        TescoScrapingAgent()
    ]
    
    private var balances: [ScrapedBalance]? {
        return Current.userDefaults.value(forDefaultsKey: .scrapedBalances) as? [ScrapedBalance]
    }
    
    // MARK: - Balance handling
    
    func persistBalance(_ balanceValue: String, forMembershipCardId cardId: String) {
        let scrapedBalance = ScrapedBalance(membershipCardId: cardId, pointsBalance: balanceValue)
        
        var persistedBalances: [ScrapedBalance] = []
        if var balances = balances {
            balances.append(scrapedBalance)
            persistedBalances = balances
        } else {
            persistedBalances = [scrapedBalance]
        }
        Current.userDefaults.set(persistedBalances, forDefaultsKey: .scrapedBalances)
    }
    
    func scrapedBalanceValue(forMembershipCardId cardId: String) -> String? {
        return balances?.first(where: { $0.membershipCardId == cardId })?.pointsBalance
    }
    
    // MARK: - Credentials handling
    
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
    
    // MARK: - Helpers

    func hasAgent(forMembershipPlanId planId: String) -> Bool {
        return agents.contains(where: { $0.membershipPlanId == planId })
    }
}
