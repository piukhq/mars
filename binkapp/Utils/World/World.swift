//
//  World.swift
//  binkapp
//
//  Created by Nick Farrant on 19/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

let Current = World()

class World {
    lazy var database = Database(named: "binkapp")
    lazy var wallet = Wallet()
}

class Wallet: CoreDataRepositoryProtocol {
    private let apiManager = ApiManager()

    private(set) var membershipCards: [CD_MembershipCard]?
    private(set) var paymentCards: [CD_PaymentCard]?
    
    /// Concurrently load both loyalty and payment wallets in abstraction
    func load() {
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        getMembershipPlans {
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        getMembershipCards {
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        getPaymentCards {
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            NotificationCenter.default.post(name: .didLoadWallet, object: nil)
        }
    }

    private func getMembershipPlans(completion: @escaping () -> Void) {
//        guard forceRefresh else {
//            fetchCoreDataObjects(forObjectType: CD_MembershipPlan.self, completion: completion)
//            return
//        }

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

    private func getMembershipCards(completion: @escaping () -> Void) {
//        guard forceRefresh else {
//            fetchCoreDataObjects(forObjectType: CD_MembershipCard.self, completion: completion)
//            return
//        }

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

    private func getPaymentCards(completion: @escaping () -> Void) {
//        guard forceRefresh else {
//            fetchCoreDataObjects(forObjectType: CD_PaymentCard.self, completion: completion)
//            return
//        }

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
