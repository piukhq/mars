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

    private(set) var membershipCards: [CD_MembershipCard]?
    private(set) var paymentCards: [CD_PaymentCard]?

    // MARK: - Public

    /// On launch, we want to return our locally persisted wallet before we go and get a refreshed copy.
    /// Should only be called once, when the tab bar is loaded and our wallet view controllers can listen for notifications.
    func launch() {
        loadWallet(forType: .local) { [weak self] in
            self?.loadWallet(forType: .reload)
        }
    }

    /// Fetch the wallets from the API.
    /// Should only be called from a pull to refresh.
    func reload() {
        loadWallet(forType: .reload)
    }

    /// Refresh from our local data
    /// Useful for calling after card deletions
    func refreshLocal() {
        loadWallet(forType: .local)
    }

    // MARK: - Private

    private func loadWallet(forType type: FetchType, completion: (() -> Void)? = nil) {
        let dispatchGroup = DispatchGroup()
        let forceRefresh = type == .reload

        dispatchGroup.enter()
        getLoyaltyWallet(forceRefresh: forceRefresh) {
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        getPaymentWallet(forceRefresh: forceRefresh) {
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            NotificationCenter.default.post(name: .didLoadWallet, object: nil)
            completion?()
        }
    }

    /// Even though we want to get the loyalty and payment card wallets asyncronously and complete once both finish regardless of order,
    /// membership cards still have a dependancy on membership plans having been downloaded.
    /// This provides a convenient way to get the loyalty wallet as a whole, while honouring that dependancy.
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

    private func getPaymentWallet(forceRefresh: Bool = false, completion: @escaping () -> Void) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_PaymentCard.self) { [weak self] cards in
                self?.paymentCards = cards
                completion()
            }
            return
        }

        let url = RequestURL.paymentCards
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
