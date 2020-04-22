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
        loadWallets(forType: .localLaunch, reloadPlans: false, isUserDriven: false) { [weak self] (success, error) in
            self?.loadWallets(forType: .reload, reloadPlans: true, isUserDriven: false) { (success, error) in
                self?.refreshManager.start()
            }
        }
    }

    /// Fetch the wallets from the API.
    /// Should only be called from a pull to refresh.
    func reload() {
        /// Not nested in a refresh manager condition, as pull to refresh should always be permitted
        loadWallets(forType: .reload, reloadPlans: true, isUserDriven: true) { [weak self] (success, error) in
            if success {
                self?.refreshManager.resetAll()
            }
        }
    }

    /// Full API refresh of loyalty and payment wallets, nested in a refresh manager condition
    /// Called each time a wallet becomes visible
    func reloadWalletsIfNecessary() {
        if refreshManager.isActive && refreshManager.canRefreshAccounts {
            loadWallets(forType: .reload, reloadPlans: false, isUserDriven: false) { [weak self] (success, error) in
                if success {
                    self?.refreshManager.resetAccountsTimer()
                }
            }
        }
    }

    /// Full API refresh of membership plans, nested in a refresh manager condition
    /// Called each time the app enters the foreground
    func refreshMembershipPlansIfNecessary() {
        if refreshManager.isActive && refreshManager.canRefreshPlans {
            loadMembershipPlans(forceRefresh: true, isUserDriven: false) { [weak self] (success, error) in
                if success {
                    self?.refreshManager.resetPlansTimer()
                }
            }
        }
    }

    /// Refresh from our local data
    /// Useful for calling after card deletions
    func refreshLocal() {
        loadWallets(forType: .localReactive, reloadPlans: false, isUserDriven: false)
    }

    var hasPaymentCards: Bool {
        return paymentCards != nil && paymentCards?.count != 0
    }

    var hasValidPaymentCards: Bool {
        guard let paymentCards = paymentCards else { return false }
        let validPaymentCards = paymentCards.filter { !$0.isExpired() }
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
            case .failure:
                guard let localPlans = self?.membershipPlans, !localPlans.isEmpty else {
                    completion(false, .failedToGetMembershipPlans)
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
                        self?.membershipCards = cards
                        completion(true, nil)
                    })
                })
            case .failure:
                completion(false, .failedToGetMembershipCards)
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
            case .failure:
                completion(false, .failedToGetPaymentCards)
            }
        }
    }
}
