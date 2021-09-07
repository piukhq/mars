//
//  Wallet.swift
//  binkapp
//
//  Created by Nick Farrant on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import WatchConnectivity

class Wallet: NSObject, CoreDataRepositoryProtocol, WalletServiceProtocol {
    private enum FetchType {
        case localLaunch // Specifically used on launch to perform desired behaviour not needed at any other time
        case localReactive // Any local fetch other than on launch
        case reload // A fetch from the API
    }
    
    private let refreshManager = WalletRefreshManager()
    var foregroundRefreshCount = 0

    private(set) var membershipPlans: [CD_MembershipPlan]?
    private(set) var membershipCards: [CD_MembershipCard]? {
        didSet {
            WidgetController().writeContentsToDisk(membershipCards: membershipCards)
        }
    }
    private(set) var paymentCards: [CD_PaymentCard]?

    private var hasLaunched = false

    var shouldDisplayLoadingIndicator: Bool {
        let shouldDisplay = !Current.userDefaults.bool(forDefaultsKey: .hasLaunchedWallet)
        Current.userDefaults.set(true, forDefaultsKey: .hasLaunchedWallet)
        return shouldDisplay
    }
    
    // Wallet Prompt debug testing
    var linkPromptDebugCellCount: Int?
    var seePromptDebugCellCount: Int?
    var storePromptDebugCellCount: Int?

    // MARK: - Public

    /// On launch, we want to return our locally persisted wallet before we go and get a refreshed copy.
    /// Should only be called once, when the tab bar is loaded and our wallet view controllers can listen for notifications.
    func launch() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        loadWallets(forType: .localLaunch, reloadPlans: false, isUserDriven: false) { [weak self] (_, _) in
            self?.loadWallets(forType: .reload, reloadPlans: true, isUserDriven: false) { (_, _) in
                self?.refreshManager.start()
                Current.pointsScrapingManager.refreshBalancesIfNecessary()
                self?.hasLaunched = true
            }
        }
    }

    /// Fetch the wallets from the API.
    /// Should only be called from a pull to refresh.
    func reload() {
        /// Not nested in a refresh manager condition, as pull to refresh should always be permitted
        loadWallets(forType: .reload, reloadPlans: true, isUserDriven: true) { [weak self] (success, _) in
            if success {
                self?.refreshManager.resetAll()
                Current.pointsScrapingManager.refreshBalancesIfNecessary()
            }
        }
    }

    /// Full API refresh of loyalty and payment wallets, nested in a refresh manager condition
    /// Called each time a wallet becomes visible
    func reloadWalletsIfNecessary(willPerformRefresh: (Bool) -> Void) {
        if refreshManager.isActive && refreshManager.canRefreshAccounts {
            willPerformRefresh(true)
            loadWallets(forType: .reload, reloadPlans: false, isUserDriven: false) { [weak self] (success, _) in
                if success {
                    self?.foregroundRefreshCount += 1
                    self?.refreshManager.resetAccountsTimer()
                    Current.pointsScrapingManager.refreshBalancesIfNecessary()
                }
            }
        } else {
            willPerformRefresh(false)
        }
    }

    /// Full API refresh of membership plans, nested in a refresh manager condition
    /// Called each time the app enters the foreground
    func refreshMembershipPlansIfNecessary() {
        if refreshManager.isActive && refreshManager.canRefreshPlans {
            loadMembershipPlans(forceRefresh: true, isUserDriven: false) { [weak self] (success, _) in
                if success {
                    self?.refreshManager.resetPlansTimer()
                }
            }
        }
    }

    /// Refresh from our local data
    /// Useful for calling after card deletions
    func refreshLocal(completion: EmptyCompletionBlock? = nil) {
        loadWallets(forType: .localReactive, reloadPlans: false, isUserDriven: false, completion: { (success, _) in
            guard success else {
                return
            }
            completion?()
        })
    }
    
    func handleAppDidEnterBackground() {
        foregroundRefreshCount = 0
    }

    func handleLogout() {
        hasLaunched = false
        membershipCards = nil
    }

    var hasPaymentCards: Bool {
        guard let paymentCards = paymentCards else { return false }
        return !paymentCards.isEmpty
    }

    var hasValidPaymentCards: Bool {
        guard let paymentCards = paymentCards else { return false }
        let validPaymentCards = paymentCards.filter { !$0.isExpired }
        return !validPaymentCards.isEmpty
    }

    // MARK: - Private

    private func loadWallets(forType type: FetchType, reloadPlans: Bool, isUserDriven: Bool, completion: ServiceCompletionSuccessHandler<WalletServiceError>? = nil) {
        let dispatchGroup = DispatchGroup()
        let forceRefresh = type == .reload
        
        /// If we are fetching wallet data from the API, then also fetch from remote config
        if forceRefresh {
            dispatchGroup.enter()
            Current.remoteConfig.fetch { success in
                guard success else {
                    NotificationCenter.default.post(name: type == .reload ? .didLoadWallet : .didLoadLocalWallet, object: nil)
                    // if this failed, the entire function should fail
                    completion?(success, nil)
                    return
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.enter()
        getLoyaltyWallet(forceRefresh: forceRefresh, reloadPlans: reloadPlans, isUserDriven: isUserDriven) { (success, error) in
            guard success else {
                NotificationCenter.default.post(name: type == .reload ? .didLoadWallet : .didLoadLocalWallet, object: nil)
                // if this failed, the entire function should fail
                completion?(success, error)
                return
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        loadPaymentCards(forceRefresh: forceRefresh, isUserDriven: isUserDriven) { (success, error) in
            guard success else {
                NotificationCenter.default.post(name: type == .reload ? .didLoadWallet : .didLoadLocalWallet, object: nil)
                // if this failed, the entire function should fail
                completion?(success, error)
                return
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            if forceRefresh {
                Current.remoteConfig.handleRemoteConfigFetch()
            }
            NotificationCenter.default.post(name: type == .reload ? .didLoadWallet : .didLoadLocalWallet, object: nil)
            completion?(true, nil)
        }
    }

    /// Even though we want to get the loyalty and payment card wallets asyncronously and complete once both finish regardless of order,
    /// membership cards still have a dependancy on membership plans having been downloaded.
    /// This provides a convenient way to get the loyalty wallet as a whole, while honouring that dependancy.
    private func getLoyaltyWallet(forceRefresh: Bool = false, reloadPlans: Bool, isUserDriven: Bool, completion: @escaping ServiceCompletionSuccessHandler<WalletServiceError>) {
        loadMembershipPlans(forceRefresh: reloadPlans, isUserDriven: isUserDriven) { [weak self] (success, error) in
            guard success else {
                completion(success, .failedToGetLoyaltyWallet)
                return
            }
            self?.loadMembershipCards(forceRefresh: forceRefresh, isUserDriven: isUserDriven, completion: { (success, error) in
                completion(success, error)
            })
        }
    }

    private func loadMembershipPlans(forceRefresh: Bool = false, isUserDriven: Bool, completion: @escaping ServiceCompletionSuccessHandler<WalletServiceError>) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_MembershipPlan.self) { [weak self] localPlans in
                self?.membershipPlans = localPlans
                completion(true, nil)
            }
            return
        }

        getMembershipPlans(isUserDriven: isUserDriven) { [weak self] result in
            switch result {
            case .success(let response):
                self?.mapCoreDataObjects(objectsToMap: response, type: CD_MembershipPlan.self, completion: {
                    self?.fetchCoreDataObjects(forObjectType: CD_MembershipPlan.self) { plans in
                        self?.membershipPlans = plans
                        completion(true, nil)
                        StorageUtility.refreshPlanImages()
                    }
                })
            case .failure(let error):
                guard let localPlans = self?.membershipPlans, !localPlans.isEmpty else {
                    completion(false, error)
                    return
                }
                completion(true, nil)
            }
        }
    }
    
    struct WatchSendableLoyaltyCard: Codable {
        let id: String
        let companyName: String
        let iconImageData: Data
        let barcodeImageData: Data
        let balanceString: String?
    }

    private func loadMembershipCards(forceRefresh: Bool = false, isUserDriven: Bool, completion: @escaping ServiceCompletionSuccessHandler<WalletServiceError>) {
        defer {
            if WCSession.default.isReachable {
                if let membershipCards = membershipCards {
                    var cardsDictArray: [[String: Any]] = []
                    
                    for card in membershipCards {
                        let iconImageData = ImageService.getImageFromDevice(forPathType: .membershipPlanIcon(plan: card.membershipPlan!))?.pngData()
                        
                        let barcodeViewModel = BarcodeViewModel(membershipCard: card)
                        let barcodeImageData = barcodeViewModel.barcodeImage(withSize: CGSize(width: 100, height: 100))!.pngData()!
                        
                        let walletCardViewModel = WalletLoyaltyCardCellViewModel(membershipCard: card)
                        let balanceString = "\(walletCardViewModel.pointsValueText ?? "") \(walletCardViewModel.pointsValueSuffixText ?? "")"
                        
                        if let object = WatchSendableLoyaltyCard(id: card.id, companyName: card.membershipPlan?.account?.companyName ?? "", iconImageData: iconImageData!, barcodeImageData: barcodeImageData, balanceString: balanceString).dictionary {
                            cardsDictArray.append(object)
                        }
                    }
                    
                    WCSession.default.sendMessage(["message": cardsDictArray], replyHandler: nil)
                }
            }
        }
        
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_MembershipCard.self) { [weak self] cards in
                guard let self = self else { return }
                self.membershipCards = cards
                self.applyLocalWalletOrder(&self.localMembershipCardsOrder, to: cards, updating: &self.membershipCards)
                completion(true, nil)
            }
            return
        }
        getMembershipCards(isUserDriven: isUserDriven) { [weak self] result in
            switch result {
            case .success(let response):
                self?.mapCoreDataObjects(objectsToMap: response, type: CD_MembershipCard.self, completion: {
                    self?.fetchCoreDataObjects(forObjectType: CD_MembershipCard.self, completion: { cards in
                        guard let self = self else { return }
                        self.membershipCards = cards
                        self.applyLocalWalletOrder(&self.localMembershipCardsOrder, to: cards, updating: &self.membershipCards)
                        completion(true, nil)
                    })
                })
            case .failure(let error):
                completion(false, error)
            }
        }
    }

    private func loadPaymentCards(forceRefresh: Bool = false, isUserDriven: Bool, completion: @escaping ServiceCompletionSuccessHandler<WalletServiceError>) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_PaymentCard.self) { [weak self] cards in
                guard let self = self else { return }
                self.paymentCards = cards
                self.applyLocalWalletOrder(&self.localPaymentCardsOrder, to: cards, updating: &self.paymentCards)
                completion(true, nil)
            }
            return
        }

        getPaymentCards(isUserDriven: isUserDriven) { [weak self] result in
            switch result {
            case .success(let response):
                self?.mapCoreDataObjects(objectsToMap: response, type: CD_PaymentCard.self, completion: {
                    self?.fetchCoreDataObjects(forObjectType: CD_PaymentCard.self) { cards in
                        guard let self = self else { return }
                        self.paymentCards = cards
                        self.applyLocalWalletOrder(&self.localPaymentCardsOrder, to: cards, updating: &self.paymentCards)
                        completion(true, nil)
                    }
                })
            case .failure(let error):
                completion(false, error)
            }
        }
    }

    func identifyMembershipPlanForBarcode(_ barcode: String, completion: @escaping (CD_MembershipPlan?) -> Void) {
        let predicate = NSPredicate(format: "commonName == 'barcode'")
        fetchCoreDataObjects(forObjectType: CD_AddField.self, predicate: predicate) { fields in
            guard let fields = fields else {
                // We have no barcode add fields, there will be no match.
                completion(nil)
                return
            }

            var hasMatched = false

            for field in fields {
                if let validation = field.validation {
                    let predicate = NSPredicate(format: "SELF MATCHES %@", validation)
                    if predicate.evaluate(with: barcode) {
                        // We have a match. We should stop this entire function at this point
                        completion(field.planAccount?.plan)
                        hasMatched = true
                        return
                    }
                }
            }

            // We haven't had any matches
            guard hasMatched else {
                completion(nil)
                return
            }
        }
    }
}

// MARK: - Local wallet ordering

extension Wallet {
    enum WalletType: String, Codable {
        case loyalty
        case payment
    }
    
    private var localMembershipCardsOrder: [String]? {
        get {
            return getLocalWalletOrder(for: .loyalty)
        }
        set {
            setLocalWalletOrder(newValue, for: .loyalty)
        }
    }

    private var localPaymentCardsOrder: [String]? {
        get {
            return getLocalWalletOrder(for: .payment)
        }
        set {
            setLocalWalletOrder(newValue, for: .payment)
        }
    }

    private func getLocalWalletOrder(for walletType: WalletType) -> [String]? {
        guard let userId = Current.userManager.currentUserId else { return nil }
        return Current.userDefaults.value(forDefaultsKey: .localWalletOrder(userId: userId, walletType: walletType)) as? [String]
    }

    private func setLocalWalletOrder(_ newValue: [String]?, for walletType: WalletType) {
        guard let order = newValue else { return }
        guard let userId = Current.userManager.currentUserId else { return }
        Current.userDefaults.set(order, forDefaultsKey: .localWalletOrder(userId: userId, walletType: walletType))
    }
    
    func reorderMembershipCard(_ card: CD_MembershipCard, from sourceIndex: Int, to destinationIndex: Int) {
        reorderWalletCard(card, in: &localMembershipCardsOrder, from: sourceIndex, to: destinationIndex, updating: &membershipCards)
    }

    func reorderPaymentCard(_ card: CD_PaymentCard, from sourceIndex: Int, to destinationIndex: Int) {
        reorderWalletCard(card, in: &localPaymentCardsOrder, from: sourceIndex, to: destinationIndex, updating: &paymentCards)
    }

    private func reorderWalletCard<C: WalletCard>(_ card: C, in localCardsOrder: inout [String]?, from sourceIndex: Int, to destinationIndex: Int, updating walletDataSource: inout [C]?) {
        /// Mutate the actual wallet datasource object
        walletDataSource?.remove(at: sourceIndex)
        walletDataSource?.insert(card, at: destinationIndex)

        /// Sync the local ordering
        localCardsOrder?.remove(at: sourceIndex)
        localCardsOrder?.insert(card.id, at: destinationIndex)
    }

    private func applyLocalWalletOrder<C: WalletCard>(_ localOrder: inout [String]?, to cards: [C]?, updating walletDataSource: inout [C]?) {
        guard let cards = cards else { return }

        /// On logout, we delete all core data objects, so the first time we fall into this method is when we attempt to load local cards, which won't exist. We should return out at this point.
        if cards.isEmpty && !hasLaunched { return }

        /// If we have a local order set
        if var order = localOrder {
            /// Remove id's from local order that don't exist in the latest cards response
            order.removeAll { cardId in
                !cards.contains(where: { $0.id == cardId })
            }

            /// Add id's to top of local order for any new cards in the response
            var newCardIds = cards.compactMap { $0.id }.filter { !order.contains($0) }
            newCardIds.reverse()
            newCardIds.forEach {
                order.insert($0, at: 0)
            }

            /// Sort cards in the custom order
            let orderedCards = order.map { cardId in
                cards.first(where: { $0.id == cardId })
            }

            /// Sync the datasource and local card order
            localOrder = order
            walletDataSource = orderedCards.compactMap({ $0 })
        } else {
            /// Sync the datasource and set the local card order
            localOrder = cards.compactMap { $0.id }
            walletDataSource = cards
        }
    }
}

// MARK: - Watch Connectivity

extension Wallet: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
