//
//  Wallet.swift
//  binkapp
//
//  Created by Nick Farrant on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class Wallet: CoreDataRepositoryProtocol {
    private let apiManager = ApiManager()

    private(set) var membershipCards: [CD_MembershipCard]?
    private(set) var paymentCards: [CD_PaymentCard]?

    // MARK: - Public

    /// On launch, we want to return our locally persisted wallet before we go and get a refreshed copy.
    /// Should only be called once, when the tab bar is loaded and our wallet view controllers can listen for notifications.
    func launch() {
        loadLocalWallet { [weak self] in
            self?.refreshWallet(completion: nil)
        }
    }

    /// Fetch the wallets from the API.
    /// Should only be called from a pull to refresh.
    func refresh() {
        refreshWallet()
    }

    // MARK: - Private

    private func refreshWallet(completion: (() -> Void)? = nil) {
        let refreshWalletDispatchGroup = DispatchGroup()

        refreshWalletDispatchGroup.enter()
        getLoyaltyWallet(forceRefresh: true) {
            refreshWalletDispatchGroup.leave()
        }

        refreshWalletDispatchGroup.enter()
        getPaymentCards(forceRefresh: true) {
            refreshWalletDispatchGroup.leave()
        }

        refreshWalletDispatchGroup.notify(queue: .main) {
            print("sending notification for refresh")
            NotificationCenter.default.post(name: .didLoadWallet, object: nil)
            completion?()
        }
    }

    private func loadLocalWallet(completion: (() -> Void)? = nil) {
        let localWalletDispatchGroup = DispatchGroup()

        localWalletDispatchGroup.enter()
        getLoyaltyWallet {
            localWalletDispatchGroup.leave()
        }

        localWalletDispatchGroup.enter()
        getPaymentCards {
            localWalletDispatchGroup.leave()
        }

        localWalletDispatchGroup.notify(queue: .main) {
            print("sending notification for local refresh")
            NotificationCenter.default.post(name: .didLoadWallet, object: nil)
            completion?()
        }
    }

    private func getLoyaltyWallet(forceRefresh: Bool = false, completion: @escaping () -> Void) {
        getMembershipPlans(forceRefresh: forceRefresh) { [weak self] in
            self?.getMembershipCards(forceRefresh: forceRefresh) {
                completion()
            }
        }
    }

    private func getMembershipPlans(forceRefresh: Bool = false, completion: @escaping () -> Void) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_MembershipPlan.self) { _ in
                completion()
            }
            return
        }

        let url = RequestURL.membershipPlans
        let method = RequestHTTPMethod.get

        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { [weak self] (response: [MembershipPlanModel]) in
            self?.mapCoreDataObjects(objectsToMap: response, type: CD_MembershipPlan.self, completion: {
                self?.fetchCoreDataObjects(forObjectType: CD_MembershipPlan.self) { _ in
                    completion()
                }
            })
        }, onError: {_ in
            print("error")
        })
    }

    private func getMembershipCards(forceRefresh: Bool = false, completion: @escaping () -> Void) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_MembershipCard.self) { [weak self] cards in
                self?.membershipCards = cards
                completion()
            }
            return
        }

        let url = RequestURL.membershipCards
        let method = RequestHTTPMethod.get

        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { [weak self] (response: [MembershipCardModel]) in
            self?.mapCoreDataObjects(objectsToMap: response, type: CD_MembershipCard.self, completion: {
                self?.fetchCoreDataObjects(forObjectType: CD_MembershipCard.self, completion: { cards in
                    self?.membershipCards = cards
                    completion()
                })
            })
        }, onError: {_ in
            print("error")
        })
    }

    private func getPaymentCards(forceRefresh: Bool = false, completion: @escaping () -> Void) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_PaymentCard.self) { [weak self] cards in
                self?.paymentCards = cards
                completion()
            }
            return
        }

        let url = RequestURL.getPaymentCards
        let method = RequestHTTPMethod.get

        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { [weak self] (response: [PaymentCardModel]) in
            self?.mapCoreDataObjects(objectsToMap: response, type: CD_PaymentCard.self, completion: {
                self?.fetchCoreDataObjects(forObjectType: CD_PaymentCard.self) { cards in
                    self?.paymentCards = cards
                    completion()
                }
            })
        }, onError: {_ in
            print("error")
        })
    }
}
