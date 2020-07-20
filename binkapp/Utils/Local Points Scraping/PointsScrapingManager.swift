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
    
    private let agents: [WebScrapable] = [
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
        guard let agent = agents.first(where: { $0.membershipPlanId == planId }) else { return }
        
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
    
    // MARK: - Balance refreshing
    
    func refreshBalancesIfNecessary() {
        getRefreshableMembershipCards { refreshableCards in
            refreshableCards.forEach { [weak self] in
                // TODO: Implement operation queues for multiple scraped cards
                guard let self = self else { return }
                
                // The utility gets set to nil when it completes, so if it's not nil it's still hard at work
                guard self.webScrapingUtility == nil else { return }
                guard let planId = $0.membershipPlan?.id else { return }
                guard let agent = self.agents.first(where: { $0.membershipPlanId == Int(planId) }) else { return }
                self.webScrapingUtility = WebScrapingUtility(containerViewController: UIViewController(), agent: agent, membershipCardId: $0.id, delegate: self)
                
                do {
                    try self.webScrapingUtility?.start()
                } catch {
                    
                }
            }
        }
    }
    
    private func getRefreshableMembershipCards(completion: @escaping ([CD_MembershipCard]) -> Void) {
        var refreshableCards: [CD_MembershipCard] = []
        fetchPointsScrapableMembershipCards { cards in
            cards?.forEach {
                if WalletRefreshManager.canRefreshScrapedValueForMembershipCard($0) {
                    refreshableCards.append($0)
                }
            }
            completion(refreshableCards)
        }
    }
    
    // MARK: - Helpers
    
    func planIdIsWebScrapable(_ planId: Int?) -> Bool {
        guard let id = planId else { return false }
        return hasAgent(forMembershipPlanId: id)
    }

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
    private func fetchPointsScrapableMembershipCards(completion: @escaping ([CD_MembershipCard]?) -> Void) {
        fetchCoreDataObjects(forObjectType: CD_MembershipCard.self) { objects in
            let scrapableCards = objects?.filter {
                guard let planIdString = $0.membershipPlan?.id, let planId = Int(planIdString) else { return false }
                return self.hasAgent(forMembershipPlanId: planId)
            }
            completion(scrapableCards)
        }
    }
    
    private func fetchMembershipCard(forId cardId: String, completion: @escaping (CD_MembershipCard?) -> Void) {
        // TODO: this could be in core data repository as a generic function
        let predicate = NSPredicate(format: "id == \(cardId)")
        fetchCoreDataObjects(forObjectType: CD_MembershipCard.self, predicate: predicate) { objects in
            completion(objects?.first)
        }
    }
    
    private func transitionToAuthorized(pointsValue: String, membershipCardId: String, agent: WebScrapable) {
        fetchMembershipCard(forId: membershipCardId) { membershipCard in
            guard let membershipCard = membershipCard else { return }
            Current.database.performBackgroundTask(with: membershipCard) { (backgroundContext, safeObject) in
                guard let membershipCard = safeObject else { return }
                
                guard let pointsValue = Double(pointsValue) else { return }
                
                // Set new balance object
                let balance = MembershipCardBalanceModel(apiId: nil, value: pointsValue, currency: agent.loyaltySchemeBalanceCurrency, prefix: agent.loyaltySchemeBalancePrefix, suffix: agent.loyaltySchemeBalanceSuffix, updatedAt: Date().timeIntervalSince1970)
                let cdBalance = balance.mapToCoreData(backgroundContext, .update, overrideID: MembershipCardBalanceModel.overrideId(forParentId: membershipCard.id))
                membershipCard.addBalancesObject(cdBalance)
                cdBalance.card = membershipCard
                
                // Set card status to authorized
                let status = MembershipCardStatusModel(apiId: nil, state: .authorised, reasonCodes: [.pointsScrapingSuccessful])
                let cdStatus = status.mapToCoreData(backgroundContext, .update, overrideID: MembershipCardStatusModel.overrideId(forParentId: membershipCard.id))
                membershipCard.status = cdStatus
                cdStatus.card = membershipCard
                
                do {
                    try backgroundContext.save()
                } catch {
                    self.transitionToFailed(membershipCardId: membershipCardId)
                }
                
                NotificationCenter.default.post(name: .webScrapingUtilityDidComplete, object: nil)
            }
        }
    }
    
    private func transitionToFailed(membershipCardId: String) {
        fetchMembershipCard(forId: membershipCardId) { membershipCard in
            guard let membershipCard = membershipCard else { return }
            Current.database.performBackgroundTask(with: membershipCard) { (backgroundContext, safeObject) in
                guard let membershipCard = safeObject else { return }
                
                // Set card status to failed
                let status = MembershipCardStatusModel(apiId: nil, state: .failed, reasonCodes: [.pointsScrapingLoginFailed])
                let cdStatus = status.mapToCoreData(backgroundContext, .update, overrideID: MembershipCardStatusModel.overrideId(forParentId: membershipCard.id))
                membershipCard.status = cdStatus
                cdStatus.card = membershipCard
                
                // If this try fails, the card will be stuck in pending until deleted and readded
                try? backgroundContext.save()
                
                NotificationCenter.default.post(name: .webScrapingUtilityDidComplete, object: nil)
            }
        }
    }
}

// MARK: - WebScrapingUtilityDelegate

extension PointsScrapingManager: WebScrapingUtilityDelegate {
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: String, forMembershipCardId cardId: String, withAgent agent: WebScrapable) {
        // Set web scraping utilty to nil, as delegate methods are only called upon completion
        webScrapingUtility = nil
        transitionToAuthorized(pointsValue: value, membershipCardId: cardId, agent: agent)
    }
    
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError, forMembershipCardId cardId: String, withAgent agent: WebScrapable) {
        // Set web scraping utilty to nil, as delegate methods are only called upon completion
        webScrapingUtility = nil
        transitionToFailed(membershipCardId: cardId)
    }
}
