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
        case failedToEnableMembershipCardForPointsScraping
        case failedToGetMembershipPlanFromRequest
        case failedToGetAgentForMembershipPlan
        
        var domain: BinkErrorDomain {
            return .pointsScrapingManager
        }
        
        var message: String {
            switch self {
            case .failedToStoreCredentials:
                return "Failed to store credentials"
            case .failedToRetrieveCredentials:
                return "Failed to retrieve credentials"
            case .failedToEnableMembershipCardForPointsScraping:
                return "Failed to enable membership card for points scraping"
            case .failedToGetMembershipPlanFromRequest:
                return "Failed to get membership plan from request"
            case .failedToGetAgentForMembershipPlan:
                return "Failed to get agent for membership plan"
            }
        }
    }
    
    // MARK: - Properties
    
    private static let baseCredentialStoreKey = "com.bink.wallet.pointsScraping.credentials.cardId_%@.%@"
    private let keychain = Keychain(service: APIConstants.bundleID)
    private var webScrapingUtility: WebScrapingUtility?
    
    private var isMasterEnabled: Bool {
        return Current.remoteConfig.boolValueForConfigKey(.localPointsCollectionMasterEnabled)
    }
    
    let agents: [WebScrapable] = [
        TescoScrapingAgent()
    ]
    
    // MARK: - Credentials handling
    
    func makeCredentials(fromFormFields fields: [FormField], membershipPlanId: String) -> WebScrapingCredentials? {
        guard let planId = Int(membershipPlanId) else { return nil }
        guard let agent = agent(forPlanId: planId) else { return nil }
        let authFields = fields.filter { $0.columnKind == .auth }
        let usernameField = authFields.first(where: { $0.title == agent.usernameFieldTitle })
        let passwordField = authFields.first(where: { $0.title == agent.passwordFieldTitle })
        
        guard let usernameValue = usernameField?.value else { return nil }
        guard let passwordValue = passwordField?.value else { return nil }
        
        return WebScrapingCredentials(username: usernameValue, password: passwordValue)
    }
    
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
    
    func enableLocalPointsScrapingForCardIfPossible(withRequest request: MembershipCardPostModel, credentials: WebScrapingCredentials, membershipCard: CD_MembershipCard) throws {
        guard planIdIsWebScrapable(request.membershipPlan) else { return }
        
        guard canEnableLocalPointsScrapingForCard(withRequest: request) else {
            throw PointsScrapingManagerError.failedToEnableMembershipCardForPointsScraping
        }
        guard let planId = request.membershipPlan else {
            throw PointsScrapingManagerError.failedToGetMembershipPlanFromRequest
        }
        guard let agent = agents.first(where: { $0.membershipPlanId == planId }) else {
            throw PointsScrapingManagerError.failedToGetAgentForMembershipPlan
        }
                
        webScrapingUtility = WebScrapingUtility(containerViewController: UIViewController().getVisibleViewController()!, agent: agent, membershipCard: membershipCard, delegate: self)
        do {
            try storeCredentials(credentials, forMembershipCardId: membershipCard.id)
            try webScrapingUtility?.start()
        } catch {
            self.transitionToFailed(membershipCard: membershipCard)
        }
    }
    
    func disableLocalPointsScraping(forMembershipCardId cardId: String) {
        removeCredentials(forMembershipCardId: cardId)
        Current.userDefaults.set(nil, forDefaultsKey: .webScrapingCookies(membershipCardId: cardId))
    }
    
    private func canEnableLocalPointsScrapingForCard(withRequest request: MembershipCardPostModel) -> Bool {
        guard let planId = request.membershipPlan else { return false }
        return hasAgent(forMembershipPlanId: planId)
    }
    
    // MARK: - Balance refreshing
    
    private var balanceRefreshQueue: [CD_MembershipCard] = []
    
    func refreshBalancesIfNecessary() {
        Current.remoteConfig.fetch { [weak self] in
            guard let self = self else { return }
            guard self.isMasterEnabled else { return }
            self.getRefreshableMembershipCards { refreshableCards in
                self.balanceRefreshQueue = refreshableCards
                self.continueBalanceRefresh()
            }
        }
    }
    
    private func continueBalanceRefresh() {
        if let newFirstObject = balanceRefreshQueue.first {
            refreshBalance(membershipCard: newFirstObject)
        }
    }
    
    private func refreshNextBalanceIfNecessary() {
        // Remove object from the top
        if let firstObject = balanceRefreshQueue.first, let index = balanceRefreshQueue.firstIndex(of: firstObject) {
            balanceRefreshQueue.remove(at: index)
        }
        
        // Get the new first object if there is one and refresh it's balance
        continueBalanceRefresh()
    }
    
    private func refreshBalance(membershipCard: CD_MembershipCard) {
        // TODO: Should we force to retry if any of these conditions fail? Otherwise, we will always have an outdated points balance
        guard membershipCard.status?.status == .authorised else { return }
        guard let planId = membershipCard.membershipPlan?.id else { return }
        guard let agent = self.agents.first(where: { $0.membershipPlanId == Int(planId) }) else { return }
        guard agentEnabled(agent) else { return }
        
        DispatchQueue.main.async {
            self.webScrapingUtility = WebScrapingUtility(containerViewController: UIViewController(), agent: agent, membershipCard: membershipCard, delegate: self)
            
            do {
                try self.webScrapingUtility?.start()
            } catch {
                self.transitionToFailed(membershipCard: membershipCard)
            }
        }
    }
    
    private func agentEnabled(_ agent: WebScrapable) -> Bool {
        if agent.merchant == .tesco {
            return true
        }
        return Current.remoteConfig.boolValueForConfigKey(.localPointsCollectionAgentEnabled(agent))
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
        guard isMasterEnabled else { return false }
        guard let id = planId else { return false }
        guard let agent = agent(forPlanId: id) else { return false }
        return agentEnabled(agent)
    }
    
    private func agent(forPlanId planId: Int) -> WebScrapable? {
        return agents.first(where: { $0.membershipPlanId == planId })
    }

    private func hasAgent(forMembershipPlanId planId: Int) -> Bool {
        return agents.contains(where: { $0.membershipPlanId == planId })
    }
    
    private func pointsScrapingDidComplete() {
        webScrapingUtility = nil
        NotificationCenter.default.post(name: .webScrapingUtilityDidComplete, object: nil)
        refreshNextBalanceIfNecessary()
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
        let predicate = NSPredicate(format: "id == \(cardId)")
        fetchCoreDataObjects(forObjectType: CD_MembershipCard.self, predicate: predicate) { objects in
            completion(objects?.first)
        }
    }
    
    private func transitionToAuthorized(pointsValue: String, membershipCard: CD_MembershipCard, agent: WebScrapable) {
        fetchMembershipCard(forId: membershipCard.id) { membershipCard in
            guard let membershipCard = membershipCard else {
                fatalError("We should never get here. If we passed in a correct membership card id, we should get a card back.")
            }
            Current.database.performBackgroundTask(with: membershipCard) { (backgroundContext, safeObject) in
                guard let membershipCard = safeObject else {
                    fatalError("We should never get here. Core data didn't return us an object, why not?")
                }
                
                guard let pointsValue = Double(pointsValue) else {
                    fatalError("We should never get here. If we have got this far, we should always be able to parse the points value correctly. Perhaps the merchant data has changed.")
//                    self.transitionToFailed(membershipCardId: membershipCard.id)
                }
                
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
                    self.transitionToFailed(membershipCard: membershipCard)
                }
            
                self.pointsScrapingDidComplete()
                BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionSuccess(membershipCard: membershipCard))
                BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionStatus(membershipCard: membershipCard))
            }
        }
    }
    
    func transitionToFailed(membershipCard: CD_MembershipCard) {
        Current.userDefaults.set(nil, forDefaultsKey: .webScrapingCookies(membershipCardId: membershipCard.id))
        
        fetchMembershipCard(forId: membershipCard.id) { membershipCard in
            guard let membershipCard = membershipCard else {
                fatalError("We should never get here. If we passed in a correct membership card id, we should get a card back.")
            }
            Current.database.performBackgroundTask(with: membershipCard) { (backgroundContext, safeObject) in
                guard let membershipCard = safeObject else {
                    fatalError("We should never get here. Core data didn't return us an object, why not?")
                }
                
                // Set card status to failed
                let status = MembershipCardStatusModel(apiId: nil, state: .failed, reasonCodes: [.pointsScrapingLoginFailed])
                let cdStatus = status.mapToCoreData(backgroundContext, .update, overrideID: MembershipCardStatusModel.overrideId(forParentId: membershipCard.id))
                membershipCard.status = cdStatus
                cdStatus.card = membershipCard
                
                // If this try fails, the card will be stuck in pending until deleted and readded
                try? backgroundContext.save()
                
                self.pointsScrapingDidComplete()
                BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionStatus(membershipCard: membershipCard))
            }
        }
    }
}

// MARK: - WebScrapingUtilityDelegate

extension PointsScrapingManager: WebScrapingUtilityDelegate {
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: String, forMembershipCard card: CD_MembershipCard, withAgent agent: WebScrapable) {
        transitionToAuthorized(pointsValue: value, membershipCard: card, agent: agent)
    }
    
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError, forMembershipCard card: CD_MembershipCard, withAgent agent: WebScrapable) {
        switch error {
        case .loginFailed:
            BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionCredentialFailure(membershipCard: card, error: error))
        default:
            BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionInternalFailure(membershipCard: card, error: error))
        }
        transitionToFailed(membershipCard: card)
    }
}
