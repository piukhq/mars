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
        case local
        case reload
    }

    private let apiManager = ApiManager()
    private let refreshManager = WalletRefreshManager()

    private(set) var membershipPlans: [CD_MembershipPlan]?
    private(set) var membershipCards: [CD_MembershipCard]?
    private(set) var paymentCards: [CD_PaymentCard]?

    // MARK: - Public

    /// On launch, we want to return our locally persisted wallet before we go and get a refreshed copy.
    /// Should only be called once, when the tab bar is loaded and our wallet view controllers can listen for notifications.
    func launch() {
        loadWallet(forType: .local) { [weak self] _ in
            self?.loadWallet(forType: .reload) { success in
                if success {
                    // Launch requests succeeded, so start the refresh manager to handle future requests
                    self?.refreshManager.start()
                }
            }
        }
    }

    /// Fetch the wallets from the API.
    /// Should only be called from a pull to refresh.
    func reload() {
        /// Not nested in a refresh manager check, as pull to refresh should always be permitted
        loadWallet(forType: .reload) { [weak self] success in
            if success {
                /// We should only reset the refresh manager if the wallet load was successful
                self?.refreshManager.reset()
            }
        }
    }

    /// Full API refresh, nested in a refresh manager condition
    /// Called each time a wallet becomes visible
    func reloadIfNecessary() {
        if refreshManager.isActive && refreshManager.canRefreshAccounts {
            reload()
        }
    }

    /// Refresh from our local data
    /// Useful for calling after card deletions
    func refreshLocal() {
        loadWallet(forType: .local)
    }

    var hasPaymentCards: Bool {
        return paymentCards != nil && paymentCards?.count != 0
    }

    // MARK: - Private

    private func loadWallet(forType type: FetchType, completion: ((Bool) -> Void)? = nil) {
        let dispatchGroup = DispatchGroup()
        let forceRefresh = type == .reload

        dispatchGroup.enter()
        getLoyaltyWallet(forceRefresh: forceRefresh) { success in
            // if this failed, the entire function should fail
            guard success else {
                completion?(success)
                return
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        getPaymentWallet(forceRefresh: forceRefresh) { success in
            // if this failed, the entire function should fail
            guard success else {
                completion?(success)
                return
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            NotificationCenter.default.post(name: .didLoadWallet, object: nil)
            completion?(true)
        }
    }

    /// Even though we want to get the loyalty and payment card wallets asyncronously and complete once both finish regardless of order,
    /// membership cards still have a dependancy on membership plans having been downloaded.
    /// This provides a convenient way to get the loyalty wallet as a whole, while honouring that dependancy.
    private func getLoyaltyWallet(forceRefresh: Bool = false, completion: @escaping (Bool) -> Void) {
        getMembershipPlans(forceRefresh: forceRefresh) { [weak self] success in
            self?.getMembershipCards(forceRefresh: forceRefresh, completion: { success in
                completion(success)
            })
        }
    }

    private func getMembershipPlans(forceRefresh: Bool = false, completion: @escaping (Bool) -> Void) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_MembershipPlan.self) { [weak self] plans in
                self?.membershipPlans = plans
                completion(true)
            }
            return
        }

        let url = RequestURL.membershipPlans
        let method = RequestHTTPMethod.get

        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { [weak self] (response: [MembershipPlanModel]) in
            self?.mapCoreDataObjects(objectsToMap: response, type: CD_MembershipPlan.self, completion: {
                self?.fetchCoreDataObjects(forObjectType: CD_MembershipPlan.self) { plans in
                    self?.membershipPlans = plans
                    completion(true)
                }
            })
        }, onError: {_ in
            completion(false)
        })
    }

    private func getMembershipCards(forceRefresh: Bool = false, completion: @escaping (Bool) -> Void) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_MembershipCard.self) { [weak self] cards in
                self?.membershipCards = cards
                completion(true)
            }
            return
        }

        let url = RequestURL.membershipCards
        let method = RequestHTTPMethod.get

        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { [weak self] (response: [MembershipCardModel]) in
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

    private func getPaymentWallet(forceRefresh: Bool = false, completion: @escaping (Bool) -> Void) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_PaymentCard.self) { [weak self] cards in
                self?.paymentCards = cards
                completion(true)
            }
            return
        }

        let url = RequestURL.paymentCards
        let method = RequestHTTPMethod.get

        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { [weak self] (response: [PaymentCardModel]) in
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
