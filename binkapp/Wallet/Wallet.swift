//
//  Wallet.swift
//  binkapp
//
//  Created by Nick Farrant on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class Wallet: CoreDataRepositoryProtocol {
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
        loadWallets(forType: .localLaunch, reloadPlans: false, isUserDriven: false) { [weak self] _ in
            self?.loadWallets(forType: .reload, reloadPlans: true, isUserDriven: false) { _ in
                self?.refreshManager.start()
            }
        }
    }

    /// Fetch the wallets from the API.
    /// Should only be called from a pull to refresh.
    func reload() {
        /// Not nested in a refresh manager condition, as pull to refresh should always be permitted
        loadWallets(forType: .reload, reloadPlans: true, isUserDriven: true) { [weak self] success in
            if success {
                self?.refreshManager.resetAll()
            }
        }
    }

    /// Full API refresh of loyalty and payment wallets, nested in a refresh manager condition
    /// Called each time a wallet becomes visible
    func reloadWalletsIfNecessary() {
        if refreshManager.isActive && refreshManager.canRefreshAccounts {
            loadWallets(forType: .reload, reloadPlans: false, isUserDriven: false) { [weak self] success in
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
            getMembershipPlans(forceRefresh: true, isUserDriven: false) { [weak self] success in
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

    private func loadWallets(forType type: FetchType, reloadPlans: Bool, isUserDriven: Bool, completion: ((Bool) -> Void)? = nil) {
        let dispatchGroup = DispatchGroup()
        let forceRefresh = type == .reload

        dispatchGroup.enter()
        getLoyaltyWallet(forceRefresh: forceRefresh, reloadPlans: reloadPlans, isUserDriven: isUserDriven) { success in
            // if this failed, the entire function should fail
            guard success else {
                completion?(success)
                return
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        getPaymentWallet(forceRefresh: forceRefresh, isUserDriven: isUserDriven) { success in
            // if this failed, the entire function should fail
            guard success else {
                completion?(success)
                return
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.shouldDisplayWalletPrompts = type == .reload || type == .localReactive
            NotificationCenter.default.post(name: type == .reload ? .didLoadWallet : .didLoadLocalWallet, object: nil)
            completion?(true)
        }
    }

    /// Even though we want to get the loyalty and payment card wallets asyncronously and complete once both finish regardless of order,
    /// membership cards still have a dependancy on membership plans having been downloaded.
    /// This provides a convenient way to get the loyalty wallet as a whole, while honouring that dependancy.
    private func getLoyaltyWallet(forceRefresh: Bool = false, reloadPlans: Bool, isUserDriven: Bool, completion: @escaping (Bool) -> Void) {
        getMembershipPlans(forceRefresh: reloadPlans, isUserDriven: isUserDriven) { [weak self] success in
            self?.getMembershipCards(forceRefresh: forceRefresh, isUserDriven: isUserDriven, completion: { success in
                completion(success)
            })
        }
    }

    private func getMembershipPlans(forceRefresh: Bool = false, isUserDriven: Bool, completion: @escaping (Bool) -> Void) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_MembershipPlan.self) { [weak self] plans in
                self?.membershipPlans = plans
                completion(true)
            }
            return
        }

        let url = RequestURL.membershipPlans
        let method = RequestHTTPMethod.get

        Current.apiManager.doRequest(url: url, httpMethod: method, isUserDriven: isUserDriven, onSuccess: { [weak self] (response: [MembershipPlanModel]) in
            self?.mapCoreDataObjects(objectsToMap: response, type: CD_MembershipPlan.self, completion: {
                self?.fetchCoreDataObjects(forObjectType: CD_MembershipPlan.self) { plans in
                    self?.membershipPlans = plans
                    completion(true)
                    StorageUtility.refreshPlanImages()
                }
            })
        }, onError: {_ in
            completion(false)
        })
    }

    private func getMembershipCards(forceRefresh: Bool = false, isUserDriven: Bool, completion: @escaping (Bool) -> Void) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_MembershipCard.self) { [weak self] cards in
                self?.membershipCards = cards
                completion(true)
            }
            return
        }

        let url = RequestURL.membershipCards
        let method = RequestHTTPMethod.get

        Current.apiManager.doRequest(url: url, httpMethod: method, isUserDriven: isUserDriven, onSuccess: { [weak self] (response: [MembershipCardModel]) in
            self?.mapCoreDataObjects(objectsToMap: response, type: CD_MembershipCard.self, completion: {
                self?.fetchCoreDataObjects(forObjectType: CD_MembershipCard.self, completion: { cards in
                    self?.membershipCards = cards
                    completion(true)
                })
            })
        }, onError: {_ in
            completion(false)
        })
    }

    private func getPaymentWallet(forceRefresh: Bool = false, isUserDriven: Bool, completion: @escaping (Bool) -> Void) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_PaymentCard.self) { [weak self] cards in
                self?.paymentCards = cards
                completion(true)
            }
            return
        }

        let url = RequestURL.paymentCards
        let method = RequestHTTPMethod.get

        Current.apiManager.doRequest(url: url, httpMethod: method, isUserDriven: isUserDriven, onSuccess: { [weak self] (response: [PaymentCardModel]) in
            self?.mapCoreDataObjects(objectsToMap: response, type: CD_PaymentCard.self, completion: {
                self?.fetchCoreDataObjects(forObjectType: CD_PaymentCard.self) { cards in
                    self?.paymentCards = cards
                    completion(true)
                }
            })
        }, onError: {_ in
            completion(false)
        })
    }
}
