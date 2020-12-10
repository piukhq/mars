//
//  Wallet.swift
//  binkapp
//
//  Created by Nick Farrant on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class Wallet: CoreDataRepositoryProtocol, WalletServiceProtocol {
    private enum FetchType {
        case localLaunch // Specifically used on launch to perform desired behaviour not needed at any other time
        case localReactive // Any local fetch other than on launch
        case reload // A fetch from the API
    }
    
    private let refreshManager = WalletRefreshManager()

    private(set) var membershipPlans: [CD_MembershipPlan]?
    private(set) var membershipCards: [CD_MembershipCard]?
    private(set) var paymentCards: [CD_PaymentCard]?

    private var localMembershipCardsOrder: [String]?

    private(set) var shouldDisplayWalletPrompts: Bool?
    var shouldDisplayLoadingIndicator: Bool {
        let shouldDisplay = !Current.userDefaults.bool(forDefaultsKey: .hasLaunchedWallet)
        Current.userDefaults.set(true, forDefaultsKey: .hasLaunchedWallet)
        return shouldDisplay
    }

    // MARK: - Public

    /// On launch, we want to return our locally persisted wallet before we go and get a refreshed copy.
    /// Should only be called once, when the tab bar is loaded and our wallet view controllers can listen for notifications.
    func launch() {
        loadWallets(forType: .localLaunch, reloadPlans: false, isUserDriven: false) { [weak self] (_, _) in
            self?.loadWallets(forType: .reload, reloadPlans: true, isUserDriven: false) { (_, _) in
                self?.refreshManager.start()
                Current.pointsScrapingManager.refreshBalancesIfNecessary()
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

        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.shouldDisplayWalletPrompts = type == .reload || type == .localReactive
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

    private func loadMembershipCards(forceRefresh: Bool = false, isUserDriven: Bool, completion: @escaping ServiceCompletionSuccessHandler<WalletServiceError>) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_MembershipCard.self) { [weak self] cards in
                self?.membershipCards = cards
                completion(true, nil)
            }
            return
        }
        getMembershipCards(isUserDriven: isUserDriven) { [weak self] result in
            switch result {
            case .success(let response):
                self?.mapCoreDataObjects(objectsToMap: response, type: CD_MembershipCard.self, completion: {
                    self?.fetchCoreDataObjects(forObjectType: CD_MembershipCard.self, completion: { cards in
                        // We get the cards from the API, in whatever order it gives us
                        // Here we should apply the local order if there is one

                        // This is the API order except moving the last card to the start. It works.
                        self?.localMembershipCardsOrder = ["39399", "43031", "42736", "42735", "42733", "41752"]

                        // This means the last time we had a local order, we only had one card.
                        // The API will return more than one, we should handle this correctly and show all of them
                        // This works
//                        self?.localMembershipCardsOrder = ["39399", "12345"]

                        // What if the API has a card that we didn't have in the local order before?
                        // If there is a locally stored order, any card id's that aren't in the order should be at the top in the order they came back from the API in.
                        // All newly added cards should also go to the top of the wallet.

                        if let order = self?.localMembershipCardsOrder {
                            // Start by ordering the cards that we get back from the API that have an id match
                            var orderedCards = order.map { orderObject in
                                cards?.first(where: { $0.id == orderObject })
                            }

                            // Sort the cards we got back from the API but we don't have a match for
                            // Create an array of cards that aren't in the orderedCards array
                            var newCards = cards?.compactMap { $0 }.filter { !orderedCards.contains($0) }

                            // Insert each new card into orderedCards
                            // Reverse the order so that they insert in the same order we get them from the API
                            newCards?.reverse()
                            newCards?.forEach {
                                orderedCards.insert($0, at: 0)
                            }

                            // Sort the cards that we have an id for, but aren't present in the API response
                            self?.localMembershipCardsOrder?.removeAll(where: { orderId in
                                !orderedCards.contains { orderedCard in
                                    orderedCard?.id == orderId
                                }
                            })

                            // Set the local order to represent the new order
                            self?.localMembershipCardsOrder = orderedCards.compactMap { $0?.id }
                            // TODO: Save this to user defaults against the user id

                            self?.membershipCards = orderedCards.compactMap({ $0 })
                        } else {
                            // If there is not, just return the cards as we got them from the API
                            self?.membershipCards = cards
                        }

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
                self?.paymentCards = cards
                completion(true, nil)
            }
            return
        }

        getPaymentCards(isUserDriven: isUserDriven) { [weak self] result in
            switch result {
            case .success(let response):
                self?.mapCoreDataObjects(objectsToMap: response, type: CD_PaymentCard.self, completion: {
                    self?.fetchCoreDataObjects(forObjectType: CD_PaymentCard.self) { cards in
                        self?.paymentCards = cards
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
