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
    }
    
    private func canEnableLocalPointsScrapingForCard(withRequest request: MembershipCardPostModel) -> Bool {
        guard let planId = request.membershipPlan else { return false }
        return hasAgent(forMembershipPlanId: planId)
    }
    
    // MARK: - Helpers

    func hasAgent(forMembershipPlanId planId: Int) -> Bool {
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
        // TODO: This should be reusable
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
                    cdBalance.card = membershipCard
                    
                    // Set card status to authorized
                    let status = MembershipCardStatusModel(apiId: nil, state: .authorised, reasonCodes: nil)
                    let cdStatus = status.mapToCoreData(backgroundContext, .update, overrideID: MembershipCardStatusModel.overrideId(forParentId: membershipCard.id))
                    membershipCard.status = cdStatus
                    cdStatus.card = membershipCard
                    
                    try? backgroundContext.save()
                }
            }
        }
    }
}

// MARK: - WebScrapingUtilityDelegate

extension PointsScrapingManager: WebScrapingUtilityDelegate {
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: String, forMembershipCardId cardId: String, withAgent agent: WebScrapable) {
        // Set web scraping utilty to nil, as delegate methods are only called upon completion
        webScrapingUtility = nil
        try? setBalanceValue(value, forMembershipCardId: cardId, withAgent: agent)
    }
    
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError, forMembershipCardId cardId: String, withAgent agent: WebScrapable) {
        // Set web scraping utilty to nil, as delegate methods are only called upon completion
        webScrapingUtility = nil
        
        // TODO: This should be reusable
        let predicate = NSPredicate(format: "id == \(cardId)")
        fetchCoreDataObjects(forObjectType: CD_MembershipCard.self, predicate: predicate) { objects in
            if let persistedMembershipCard = objects?.first {
                Current.database.performBackgroundTask(with: persistedMembershipCard) { (backgroundContext, safeObject) in
                    guard let membershipCard = safeObject else { return }
                    
                    // Set card status to failed
                    let status = MembershipCardStatusModel(apiId: nil, state: .failed, reasonCodes: nil)
                    let cdStatus = status.mapToCoreData(backgroundContext, .update, overrideID: MembershipCardStatusModel.overrideId(forParentId: membershipCard.id))
                    membershipCard.status = cdStatus
                    
                    try? backgroundContext.save()
                }
            }
        }
    }
}
