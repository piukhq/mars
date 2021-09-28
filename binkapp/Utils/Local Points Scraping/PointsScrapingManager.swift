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
    
    enum CredentialStoreType: String, Codable {
        case username
        case password
        case cardNumber
    }
    
    class QueuedItem {
        let card: CD_MembershipCard
        var isBalanceRefresh: Bool
        var isProcessing = false
        var requiresRetry = false
        
        init(card: CD_MembershipCard, isBalanceRefresh: Bool) {
            self.card = card
            self.isBalanceRefresh = isBalanceRefresh
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
    
    private var config: RemoteConfigFile.LocalPointsCollection? {
        return Current.remoteConfig.configFile?.localPointsCollection
    }
    
    private var isEnabled: Bool {
        return config?.enabled ?? false
    }
    
    var isDebugMode: Bool {
        return Current.userDefaults.bool(forDefaultsKey: .lpcDebugMode)
    }
    
    var agents: [LocalPointsCollectable] {
        return config?.agents ?? []
    }
    
    var processingQueue: [QueuedItem] = []
    
    func start() {
        webScrapingUtility = WebScrapingUtility(delegate: self)
    }
    
    // MARK: - Credentials handling
    
    func makeCredentials(fromFormFields fields: [FormField], membershipPlanId: String) -> WebScrapingCredentials? {
        guard let planId = Int(membershipPlanId) else { return nil }
        guard let agent = agent(forPlanId: planId) else { return nil }
        
        let authFields = fields.filter { $0.columnKind == .lpcAuth }
        let usernameField = authFields.first(where: { $0.fieldCommonName == agent.fields?.usernameFieldCommonName })
        let passwordField = authFields.first(where: { $0.fieldCommonName == .password })
        
        guard let usernameValue = usernameField?.value else { return nil }
        guard let passwordValue = passwordField?.value else { return nil }
        
        if let requiredCredentials = agent.fields?.requiredCredentials, requiredCredentials.contains(.cardNumber) {
            let addFields = fields.filter { $0.columnKind == .add }
            let cardNumberField = addFields.first(where: { $0.fieldCommonName == .cardNumber })
            let cardNumberValue = cardNumberField?.value
            return WebScrapingCredentials(username: usernameValue, password: passwordValue, cardNumber: cardNumberValue)
        }
        
        return WebScrapingCredentials(username: usernameValue, password: passwordValue)
    }
    
    private func storeCredentials(_ credentials: WebScrapingCredentials, forMembershipCardId cardId: String) throws {
        do {
            try keychain.set(credentials.username, key: keychainKeyForCardId(cardId, credentialType: .username))
            try keychain.set(credentials.password, key: keychainKeyForCardId(cardId, credentialType: .password))
            
            if let cardNumber = credentials.cardNumber {
                try keychain.set(cardNumber, key: keychainKeyForCardId(cardId, credentialType: .cardNumber))
            }
        } catch {
            throw PointsScrapingManagerError.failedToStoreCredentials
        }
    }
    
    func retrieveCredentials(forMembershipCardId cardId: String) throws -> WebScrapingCredentials {
        do {
            guard let username = try keychain.get(keychainKeyForCardId(cardId, credentialType: .username)), let password = try keychain.get(keychainKeyForCardId(cardId, credentialType: .password)) else {
                throw PointsScrapingManagerError.failedToRetrieveCredentials
            }
            
            let cardNumber = try? keychain.get(keychainKeyForCardId(cardId, credentialType: .cardNumber))
            
            return WebScrapingCredentials(username: username, password: password, cardNumber: cardNumber)
        } catch {
            throw PointsScrapingManagerError.failedToRetrieveCredentials
        }
    }
    
    private func removeCredentials(forMembershipCardId cardId: String) {
        try? keychain.remove(keychainKeyForCardId(cardId, credentialType: .username))
        try? keychain.remove(keychainKeyForCardId(cardId, credentialType: .password))
        try? keychain.remove(keychainKeyForCardId(cardId, credentialType: .cardNumber))
    }
    
    private func keychainKeyForCardId(_ cardId: String, credentialType: CredentialStoreType) -> String {
        return String(format: PointsScrapingManager.baseCredentialStoreKey, cardId, credentialType.rawValue)
    }
    
    // MARK: - Add/Auth handling
    
    func enableLocalPointsScrapingForCardIfPossible(withRequest request: MembershipCardPostModel, credentials: WebScrapingCredentials, membershipCard: CD_MembershipCard) throws {
        let itemToProcess = QueuedItem(card: membershipCard, isBalanceRefresh: false)
        
        guard planIdIsWebScrapable(request.membershipPlan) else { return }
        
        guard canEnableLocalPointsScrapingForCard(withRequest: request) else {
            transitionToFailed(item: itemToProcess)
            throw PointsScrapingManagerError.failedToEnableMembershipCardForPointsScraping
        }
    
        do {
            try storeCredentials(credentials, forMembershipCardId: membershipCard.id)
            
            addQueuedItem(itemToProcess)
            processQueuedItems()
        } catch {
            self.transitionToFailed(item: itemToProcess)
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
    
    func performBalanceRefresh(for card: CD_MembershipCard) {
        let queuedItem = QueuedItem(card: card, isBalanceRefresh: true)
        addQueuedItem(queuedItem)
        processQueuedItems()
    }
    
    private func addQueuedItem(_ item: QueuedItem) {
        if processingQueue.contains(where: { $0.card.id == item.card.id }) { return }
        processingQueue.append(item)
    }
    
    private func processQueuedItems() {
        guard !processingQueue.isEmpty else { return }
        
        guard let itemToProcess = processingQueue.first(where: { $0.isProcessing == false && $0.requiresRetry == false }) else { return }
        guard let planIdString = itemToProcess.card.membershipPlan?.id, let planId = Int(planIdString) else {
            self.transitionToFailed(item: itemToProcess)
            return
        }
        guard let agent = agents.first(where: { $0.membershipPlanId == planId }) else {
            self.transitionToFailed(item: itemToProcess)
            return
        }

        do {
            try webScrapingUtility?.start(agent: agent, item: itemToProcess)
        } catch {
            self.transitionToFailed(item: itemToProcess)
        }
    }
    
    func processRetry(for card: CD_MembershipCard) {
        guard let itemToProcess = processingQueue.first(where: { $0.card.id == card.id }) else {
            fatalError("Could not build item to process")
        }
        guard let planIdString = itemToProcess.card.membershipPlan?.id, let planId = Int(planIdString) else {
            self.transitionToFailed(item: itemToProcess)
            return
        }
        guard let agent = agents.first(where: { $0.membershipPlanId == planId }) else {
            self.transitionToFailed(item: itemToProcess)
            return
        }

        do {
            transitionToPending(item: itemToProcess)
            try webScrapingUtility?.start(agent: agent, item: itemToProcess)
        } catch {
            self.transitionToFailed(item: itemToProcess)
        }
    }
    
    func refreshBalancesIfNecessary() {
        guard self.isEnabled else { return }
        self.getRefreshableMembershipCards { [weak self] refreshableCards in
            refreshableCards.forEach { self?.addQueuedItem(QueuedItem(card: $0, isBalanceRefresh: true)) }
            self?.processQueuedItems()
        }
    }
    
    func agentEnabled(_ agent: LocalPointsCollectable) -> Bool {
        if APIConstants.isProduction {
            return agent.enabled?.ios ?? false
        } else {
            return agent.enabled?.iosDebug ?? false
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
        guard isEnabled else { return false }
        guard let id = planId else { return false }
        guard let agent = agent(forPlanId: id) else { return false }
        return agentEnabled(agent)
    }
    
    func agent(forPlanId planId: Int) -> LocalPointsCollectable? {
        return agents.first(where: { $0.membershipPlanId == planId })
    }

    private func hasAgent(forMembershipPlanId planId: Int) -> Bool {
        return agents.contains(where: { $0.membershipPlanId == planId })
    }
    
    private func pointsScrapingDidComplete(for item: QueuedItem) {
        NotificationCenter.default.post(name: .webScrapingUtilityDidUpdate, object: nil)
        
        /// If requiresRetry is false, then we know the item either succeeded points collection, or failed it's only retry. In either case, remove the item from the processing queue
        /// If requiredRetry is true, then we know we want to perform a retry, so we should leave the item in the queue. It won't be processed with other cards, but only when the points module in LCD is tapped
        
        processingQueue.removeAll(where: { $0.card.id == item.card.id && $0.requiresRetry == false })
        processQueuedItems()
    }

    func isCurrentlyScraping(forMembershipCard card: CD_MembershipCard) -> Bool {
        return processingQueue.contains(where: { $0.card == card })
    }
    
    func debug() {
        webScrapingUtility?.debug()
    }
    
    func canAttemptRetry(for card: CD_MembershipCard) -> Bool {
        /// Is the membership card in the processingQueue, with requiresRetry set to true?
        if let _ = processingQueue.first(where: { $0.card.id == card.id && $0.requiresRetry && !$0.isProcessing }) {
            return true
        }
        return false
    }
    
    func handleLogout() {
        webScrapingUtility?.stop()
        processingQueue.removeAll()
        fetchPointsScrapableMembershipCards { cards in
            cards?.compactMap { $0.id }.forEach { id in
                self.removeCredentials(forMembershipCardId: id)
            }
        }
    }
    
    func handleDelete(for card: CD_MembershipCard) {
        if isCurrentlyScraping(forMembershipCard: card) {
            webScrapingUtility?.stop()
        }
        processingQueue.removeAll(where: { $0.card == card })
        disableLocalPointsScraping(forMembershipCardId: card.id)
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
    
    private func transitionToAuthorized(pointsValue: Int, item: QueuedItem, agent: LocalPointsCollectable) {
        fetchMembershipCard(forId: item.card.id) { membershipCard in
            guard let membershipCard = membershipCard else {
                fatalError("We should never get here. If we passed in a correct membership card id, we should get a card back.")
            }
            Current.database.performBackgroundTask(with: membershipCard) { (backgroundContext, safeObject) in
                guard let membershipCard = safeObject else {
                    fatalError("We should never get here. Core data didn't return us an object, why not?")
                }
                
                // Set new balance object
                let balance = MembershipCardBalanceModel(apiId: nil, value: Double(pointsValue), currency: agent.loyaltyScheme?.balanceCurrency, prefix: agent.loyaltyScheme?.balancePrefix, suffix: agent.loyaltyScheme?.balanceSuffix, updatedAt: Date().timeIntervalSince1970)
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
                    self.transitionToFailed(item: item)
                }
                
                self.pointsScrapingDidComplete(for: item)

                BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionSuccess(membershipCard: membershipCard))
                BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionStatus(membershipCard: membershipCard))
            }
        }
    }
    
    func transitionToFailed(item: QueuedItem) {
        /// If the item has shouldAttemptRetry = true, then we know that it is the retry that has failed and we should remove the processing item and ask the user for credentials next time
        if item.requiresRetry {
            removeCredentials(forMembershipCardId: item.card.id)
        }
        
        /// If the item required a retry, it has attempted that and now doesn't require a retry
        /// If the item didn't require a retry, then this was it's first attempt and we can perform a retry
        /// So, let's toggle it!
        item.requiresRetry.toggle()
        
        fetchMembershipCard(forId: item.card.id) { membershipCard in
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
                
                do {
                    try backgroundContext.save()
                } catch {
                    self.transitionToFailed(item: item)
                }
                
                self.pointsScrapingDidComplete(for: item)
                
                BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionStatus(membershipCard: membershipCard))
            }
        }
    }
    
    func transitionToPending(item: QueuedItem) {
        fetchMembershipCard(forId: item.card.id) { membershipCard in
            guard let membershipCard = membershipCard else {
                fatalError("We should never get here. If we passed in a correct membership card id, we should get a card back.")
            }
            Current.database.performBackgroundTask(with: membershipCard) { (backgroundContext, safeObject) in
                guard let membershipCard = safeObject else {
                    fatalError("We should never get here. Core data didn't return us an object, why not?")
                }
                
                // Set card status to pending
                let status = MembershipCardStatusModel(apiId: nil, state: .pending, reasonCodes: [.attemptingToScrapePointsValue])
                let cdStatus = status.mapToCoreData(backgroundContext, .update, overrideID: MembershipCardStatusModel.overrideId(forParentId: membershipCard.id))
                membershipCard.status = cdStatus
                cdStatus.card = membershipCard
                
                do {
                    try backgroundContext.save()
                    NotificationCenter.default.post(name: .webScrapingUtilityDidUpdate, object: nil)
                } catch {
                    self.transitionToFailed(item: item)
                }
            }
        }
    }
}

// MARK: - WebScrapingUtilityDelegate

extension PointsScrapingManager: WebScrapingUtilityDelegate {
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: Int, item: QueuedItem, withAgent agent: LocalPointsCollectable) {
        if #available(iOS 14.0, *) {
            BinkLogger.infoPrivateHash(event: WalletLoggerEvent.pointsScrapingSuccess, value: item.card.id)
        }
        transitionToAuthorized(pointsValue: value, item: item, agent: agent)
    }
    
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError, item: QueuedItem, withAgent agent: LocalPointsCollectable) {
        if item.isBalanceRefresh, WalletRefreshManager.cardCanRetainStaleBalance(item.card) {
            self.pointsScrapingDidComplete(for: item)
            return
        }
        
        if let merchant = agent.merchant {
            SentryService.triggerException(.localPointsCollectionFailed(error, merchant, balanceRefresh: item.isBalanceRefresh))
        }
        
        switch error {
        case .incorrectCredentials:
            BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionCredentialFailure(membershipCard: item.card, error: error))
        default:
            BinkAnalytics.track(LocalPointsCollectionEvent.localPointsCollectionInternalFailure(membershipCard: item.card, error: error))
        }
        
        if #available(iOS 14.0, *) {
            BinkLogger.error(WalletLoggerError.pointsScrapingFailure, value: error.message)
        }
        
        transitionToFailed(item: item)
    }
}
