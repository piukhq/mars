//
//  LoyaltyWalletRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import Alamofire
import Keys
import CoreData

class LoyaltyWalletRepository {
    private let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func getMembershipCards(forceRefresh: Bool = false, completion: @escaping ([CD_MembershipCard]?) -> Void) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_MembershipCard.self, completion: completion)
            return
        }

        let url = RequestURL.membershipCards
        let method = RequestHTTPMethod.get
        
        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { [weak self] (response: [MembershipCardModel]) in
            self?.mapCoreDataObjects(objectsToMap: response, completion: {
                self?.fetchCoreDataObjects(forObjectType: CD_MembershipCard.self, completion: completion)
            })
        }, onError: {_ in 
            print("error")
        })
    }
    
    func getMembershipPlans(forceRefresh: Bool = false, completion: @escaping ([CD_MembershipPlan]?) -> Void) {
        guard forceRefresh else {
            fetchCoreDataObjects(forObjectType: CD_MembershipPlan.self, completion: completion)
            return
        }

        let url = RequestURL.membershipPlans
        let method = RequestHTTPMethod.get
        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { [weak self] (response: [MembershipPlanModel]) in
            self?.mapCoreDataObjects(objectsToMap: response, completion: {
                self?.fetchCoreDataObjects(forObjectType: CD_MembershipPlan.self, completion: completion)
            })
        }, onError: {_ in 
            print("error")
        })
    }

    func deleteMembershipCard(id: String, completion: @escaping (Any) -> Void) {
        let url = RequestURL.deleteMembershipCard(cardId: id)
        let method = RequestHTTPMethod.delete
        
        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: EmptyResponse) in
            completion(response)
        }, onError: {_ in 
            print("error")
        })
    }
}

// MARK: - Core Data Interaction
extension LoyaltyWalletRepository {
    private func mapCoreDataObjects<T: CoreDataMappable>(objectsToMap objects: [T], completion: @escaping () -> Void) {
        Current.database.performBackgroundTask { context in
            objects.forEach {
                _ = $0.mapToCoreData(context, .delta, overrideID: nil)
            }

            try? context.save()

            completion()
        }
    }

    private func fetchCoreDataObjects<T: NSManagedObject>(forObjectType objectType: T.Type, completion: @escaping ([T]?) -> Void) {
        DispatchQueue.main.async {
            Current.database.performTask { context in
                let objects = context.fetchAll(objectType)
                completion(objects)
            }
        }
    }

    private func trashLocalObjects<T: NSManagedObject>(forObjectType objectType: T.Type, completion: @escaping () -> Void) {
        Current.database.performBackgroundTask { context in
            context.deleteAll(objectType)
            try? context.save()
            completion()
        }
    }
}
