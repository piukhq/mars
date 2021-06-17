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
    
    class QueuedItem {
        let card: CD_MembershipCard
        var isProcessing = false
        
        init(card: CD_MembershipCard) {
            self.card = card
        }
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
    
    var isDebugMode: Bool {
        return Current.userDefaults.bool(forDefaultsKey: .lpcDebugMode)
    }
    
    let agents: [WebScrapable] = [
        TescoScrapingAgent(),
        BootsScrapingAgent(),
        MorrisonsScrapingAgent(),
        SuperdrugScrapingAgent(),
        HeathrowScrapingAgent(),
        PerfumeShopScrapingAgent(),
        WaterstonesScrapingAgent()
    ]
    
    var processingQueue: [QueuedItem] = []
    
    func start() {
        webScrapingUtility = WebScrapingUtility(delegate: self)
    }
    
    // MARK: - Credentials handling
    
    func makeCredentials(fromFormFields fields: [FormField], membershipPlanId: String) -> WebScrapingCredentials? {
        guard let planId = Int(membershipPlanId) else { return nil }
        guard let agent = agent(forPlanId: planId) else { return nil }
        let authFields = fields.filter { $0.columnKind == .lpcAuth }
        let usernameField = authFields.first(where: { $0.fieldCommonName == agent.usernameField })
        let passwordField = authFields.first(where: { $0.fieldCommonName == .password })
        
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
            guard let username = try keychain.get(keychainKeyForCardId(cardId, credentialType: .username)), let password = try keychain.get(keychainKeyForCardId(cardId, credentialType: .password)) else {
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
        
        do {
            try storeCredentials(credentials, forMembershipCardId: membershipCard.id)
            
            addQueuedItem(QueuedItem(card: membershipCard))
            processQueuedItems()
        } catch {
            self.transitionToFailed(membershipCard: membershipCard)
        }
    }
    
    func disableLocalPointsScraping(forMembershipCardId cardId: String) {
        removeCredentials(forMembershipCardId: cardId)
    }
    
    private func canEnableLocalPointsScrapingForCard(withRequest request: MembershipCardPostModel) -> Bool {
        guard let planId = request.membershipPlan else { return false }
        return hasAgent(forMembershipPlanId: planId)
    }
    
    // MARK: - Processing queue
    
    private func addQueuedItem(_ item: QueuedItem) {
        if processingQueue.contains(where: { $0.card.id == item.card.id }) { return }
        processingQueue.append(item)
    }
    
    private func processQueuedItems() {
        guard !processingQueue.isEmpty else { return }
        
        guard let itemToProcess = processingQueue.first(where: { $0.isProcessing == false }) else { return }
        guard let planIdString = itemToProcess.card.membershipPlan?.id, let planId = Int(planIdString) else {
            self.transitionToFailed(membershipCard: itemToProcess.card)
            return
        }
        guard let agent = agents.first(where: { $0.membershipPlanId == planId }) else {
            self.transitionToFailed(membershipCard: itemToProcess.card)
            return
        }

        do {
            try webScrapingUtility?.start(agent: agent, item: itemToProcess)
        } catch {
            self.transitionToFailed(membershipCard: itemToProcess.card)
        }
    }
    
    func refreshBalancesIfNecessary() {
        Current.remoteConfig.fetch { [weak self] in
            guard let self = self else { return }
            guard self.isMasterEnabled else { return }
            self.getRefreshableMembershipCards { [weak self] refreshableCards in
                refreshableCards.forEach { self?.addQueuedItem(QueuedItem(card: $0)) }
                self?.processQueuedItems()
            }
        }
    }
    
    func agentEnabled(_ agent: WebScrapable) -> Bool {
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
    
    func agent(forPlanId planId: Int) -> WebScrapable? {
        return agents.first(where: { $0.membershipPlanId == planId })
    }

    private func hasAgent(forMembershipPlanId planId: Int) -> Bool {
        return agents.contains(where: { $0.membershipPlanId == planId })
    }
    
    private func pointsScrapingDidComplete(for card: CD_MembershipCard) {
        NotificationCenter.default.post(name: .webScrapingUtilityDidComplete, object: nil)
        
        /// Clear membership card from processing queue
        processingQueue.removeAll(where: { $0.card.id == card.id })
        processQueuedItems()
    }

    func isCurrentlyScraping(forMembershipCard card: CD_MembershipCard) -> Bool {
        return webScrapingUtility?.isCurrentlyScraping(forMembershipCard: card) == true
    }
    
    func debug() {
        webScrapingUtility?.debug()
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
    
    private func transitionToAuthorized(pointsValue: Int, membershipCard: CD_MembershipCard, agent: WebScrapable) {
        fetchMembershipCard(forId: membershipCard.id) { membershipCard in
            guard let membershipCard = membershipCard else {
                fatalError("We should never get here. If we passed in a correct membership card id, we should get a card back.")
            }
            Current.database.performBackgroundTask(with: membershipCard) { (backgroundContext, safeObject) in
                guard let membershipCard = safeObject else {
                    fatalError("We should never get here. Core data didn't return us an object, why not?")
                }
                
                // Set new balance object
                let balance = MembershipCardBalanceModel(apiId: nil, value: Double(pointsValue), currency: agent.loyaltySchemeBalanceCurrency, prefix: agent.loyaltySchemeBalancePrefix, suffix: agent.loyaltySchemeBalanceSuffix, updatedAt: Date().timeIntervalSince1970)
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

                self.pointsScrapingDidComplete(for: membershipCard)
                BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionSuccess(membershipCard: membershipCard))
                BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionStatus(membershipCard: membershipCard))
            }
        }
    }
    
    func transitionToFailed(membershipCard: CD_MembershipCard) {
        removeCredentials(forMembershipCardId: membershipCard.id)
        
        fetchMembershipCard(forId: membershipCard.id) { membershipCard in
            guard let membershipCard = membershipCard else {
                fatalError("We should never get here. If we passed in a correct membership card id, we should get a card back.")
            }
            Current.database.performBackgroundTask(with: membershipCard) { (backgroundContext, safeObject) in
                guard let membershipCard = safeObject else {
                    fatalError("We should never get here. Core data didn't return us an object, why not?")
                }
                
                // Remove balance objects
                if let balances = membershipCard.formattedBalances {
                    for balance in balances {
                        membershipCard.removeBalancesObject(balance)
                    }
                }
                
                // Set card status to failed
                let status = MembershipCardStatusModel(apiId: nil, state: .failed, reasonCodes: [.pointsScrapingLoginFailed])
                let cdStatus = status.mapToCoreData(backgroundContext, .update, overrideID: MembershipCardStatusModel.overrideId(forParentId: membershipCard.id))
                membershipCard.status = cdStatus
                cdStatus.card = membershipCard
                
                // If this try fails, the card will be stuck in pending until deleted and readded
                try? backgroundContext.save()
                
                self.pointsScrapingDidComplete(for: membershipCard)
                BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionStatus(membershipCard: membershipCard))
            }
        }
    }
}

// MARK: - WebScrapingUtilityDelegate

extension PointsScrapingManager: WebScrapingUtilityDelegate {
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: Int, forMembershipCard card: CD_MembershipCard, withAgent agent: WebScrapable) {
        if #available(iOS 14.0, *) {
            BinkLogger.infoPrivateHash(event: WalletLoggerEvent.pointsScrapingSuccess, value: card.id)
        }
        transitionToAuthorized(pointsValue: value, membershipCard: card, agent: agent)
    }
    
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError, forMembershipCard card: CD_MembershipCard, withAgent agent: WebScrapable) {
        switch error {
        case .incorrectCredentials:
            BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionCredentialFailure(membershipCard: card, error: error))
        default:
            BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionInternalFailure(membershipCard: card, error: error))
        }
        if #available(iOS 14.0, *) {
            BinkLogger.error(WalletLoggerError.pointsScrapingFailure, value: error.message)
        }
        transitionToFailed(membershipCard: card)
    }
}
