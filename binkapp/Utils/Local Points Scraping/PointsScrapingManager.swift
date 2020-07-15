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
    
    enum ScrapedBalanceStatus {
        case authorized
        case pending
        case failed
    }
    
    struct ScrapedBalance {
        var membershipCardId: String
        var pointsBalance: String
        var status: ScrapedBalanceStatus = .pending
        
        mutating func setStatus(_ status: ScrapedBalanceStatus) {
            self.status = status
            // TODO: Update persisted balances
        }
    }
    
    // MARK: - Error handling
    
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
    
    // MARK: - Properties
    
    private static let baseCredentialStoreKey = "com.bink.wallet.pointsScraping.credentials.cardId_%@.%@"
    private let keychain = Keychain(service: APIConstants.bundleID)
    private var webScrapingUtility: WebScrapingUtility?
    
    private let agents: [PointsScrapingAgent] = [
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
    
    func clearBalance(forMembershipCardId cardId: String) {
        guard var balances = balances else { return }
        if let indexToRemove = balances.firstIndex(where: { $0.membershipCardId == cardId }) {
            balances.remove(at: indexToRemove)
            Current.userDefaults.set(balances, forDefaultsKey: .scrapedBalances)
        }
    }
    
    func scrapedBalanceValue(forMembershipCardId cardId: String) -> String? {
        return balances?.first(where: { $0.membershipCardId == cardId })?.pointsBalance
    }
    
    // MARK: - Credentials handling
    
    private func storeCredentials(_ credentials: WebScrapingCredentials, forMembershipCardId cardId: String) throws {
        do {
            try keychain.set(credentials.username, key: keychainKeyForCardId(cardId, credentialType: .username))
            try keychain.set(credentials.password, key: keychainKeyForCardId(cardId, credentialType: .password))
        } catch {
            throw PointsScrapingManagerError.failedToStoreCredentials
        }
    }
    
    func retrieveCredentials(forMembershipCardId cardId: String) throws -> WebScrapingCredentials {
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
    
    private func removeCredentials(forMembershipCardId cardId: String) {
        try? keychain.remove(keychainKeyForCardId(cardId, credentialType: .username))
        try? keychain.remove(keychainKeyForCardId(cardId, credentialType: .password))
    }
    
    private func keychainKeyForCardId(_ cardId: String, credentialType: CredentialStoreType) -> String {
        return String(format: PointsScrapingManager.baseCredentialStoreKey, cardId, credentialType.rawValue)
    }
    
    // MARK: - Add/Auth handling
    
    func enableLocalPointsScrapingForCardIfPossible(withRequest request: MembershipCardPostModel, credentials: WebScrapingCredentials, membershipCardId: String) throws {
        guard canEnableLocalPointsScrapingForCard(withRequest: request) else { return }
        guard let planId = request.membershipPlan else { return }
        guard var agent = agents.first(where: { $0.membershipPlanId == planId }) else { return }
        guard let membershipCardIdInt = Int(membershipCardId) else { return }
        agent.addMembershipCardId(membershipCardIdInt)
        
        try? storeCredentials(credentials, forMembershipCardId: membershipCardId)
        
        webScrapingUtility = WebScrapingUtility(containerViewController: UIViewController(), agent: agent, membershipCardId: membershipCardId, delegate: self)
        try? webScrapingUtility?.start()
    }
    
    func disableLocalPointsScraping(forMembershipCardId cardId: String) {
        removeCredentials(forMembershipCardId: cardId)
        clearBalance(forMembershipCardId: cardId)
    }
    
    private func canEnableLocalPointsScrapingForCard(withRequest request: MembershipCardPostModel) -> Bool {
        guard let planId = request.membershipPlan else { return false }
        return hasAgent(forMembershipPlanId: planId)
    }
    
    // MARK: - Helpers

    private func hasAgent(forMembershipPlanId planId: Int) -> Bool {
        return agents.contains(where: { $0.membershipPlanId == planId })
    }
    
    private func makeCredentials(fromRequest request: MembershipCardPostModel) -> WebScrapingCredentials? {
        // TODO: These should be in the agent, as they wont all be the same column name, right?
        if let username = request.account?.authoriseFields?.first(where: { $0.column == "Email" })?.value,
            let password = request.account?.authoriseFields?.first(where: { $0.column == "Password" })?.value {
            return WebScrapingCredentials(username: username, password: password)
        }
        return nil
    }
}

// MARK: - Core Data interaction
extension PointsScrapingManager: CoreDataRepositoryProtocol {
    func setBalanceValue(_ value: String, forMembershipCardId cardId: String, withAgent agent: WebScrapable) throws {
        let predicate = NSPredicate(format: "id == \(cardId)")
        fetchCoreDataObjects(forObjectType: CD_MembershipCard.self, predicate: predicate) { objects in
            if let persistedMembershipCard = objects?.first {
                Current.database.performBackgroundTask(with: persistedMembershipCard) { (backgroundContext, safeObject) in
                    guard let membershipCard = safeObject else { return }
                    guard let pointsValue = Double(value) else { return }
                    
                    // Set new balance object
                    let balance = MembershipCardBalanceModel(apiId: nil, value: pointsValue, currency: agent.loyaltySchemeBalanceCurrency, prefix: agent.loyaltySchemeBalancePrefix, suffix: agent.loyaltySchemeBalanceSuffix, updatedAt: Date().timeIntervalSince1970)
                    let cdBalance = balance.mapToCoreData(backgroundContext, .update, overrideID: MembershipCardBalanceModel.overrideId(forParentId: membershipCard.id))
                    membershipCard.addBalancesObject(cdBalance)
                    
                    // Set card status to authorized
                    let status = MembershipCardStatusModel(apiId: nil, state: .authorised, reasonCodes: nil)
                    let cdStatus = status.mapToCoreData(backgroundContext, .update, overrideID: MembershipCardStatusModel.overrideId(forParentId: membershipCard.id))
                    membershipCard.status = cdStatus
                    
                    try? backgroundContext.save()
                }
            }
        }
    }
}

// MARK: - WebScrapingUtilityDelegate

extension PointsScrapingManager: WebScrapingUtilityDelegate {
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: String, forMembershipCardId cardId: String, withAgent agent: WebScrapable) {
        try? setBalanceValue(value, forMembershipCardId: cardId, withAgent: agent)
    }
    
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError) {
        // TODO: Set balances to nil? And status to failed
        print(error)
    }
}
