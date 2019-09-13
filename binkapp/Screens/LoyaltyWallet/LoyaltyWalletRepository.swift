//
//  LoyaltyWalletRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import Alamofire
import Keys

class LoyaltyWalletRepository {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func getMembershipCards(forceRefresh: Bool = false, completion: @escaping ([CD_MembershipCard]?) -> Void) {
        var membershipCards: [MembershipCardModel]?

        func fetchCoreDataObjects(completion: @escaping ([CD_MembershipCard]?) -> Void) {
            let database = Database(named: "binkapp")
            database.performBackgroundTask { context in
                membershipCards?.forEach {
                    $0.mapToCoreData(context, .delta, overrideID: nil)
                }

                try? context.save()

                DispatchQueue.main.async {
                    database.performTask { context in
                        let objects = context.fetchAll(CD_MembershipCard.self)
                        completion(objects)
                    }
                }
            }
        }

        guard forceRefresh else {
            fetchCoreDataObjects(completion: completion)
            return
        }

        let url = RequestURL.membershipCards
        let method = RequestHTTPMethod.get
        
        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: [MembershipCardModel]) in
            membershipCards = response
            fetchCoreDataObjects(completion: completion)
        }, onError: {_ in 
            print("error")
        })
    }
    
    func getMembershipPlans(completion: @escaping ([CD_MembershipPlan]) -> Void) {
        let url = RequestURL.membershipPlans
        let method = RequestHTTPMethod.get
        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: [MembershipPlanModel]) in

            let database = Database(named: "binkapp")
            database.performBackgroundTask { context in
                response.forEach {
                    let cdObject = $0.mapToCoreData(context, .delta, overrideID: nil)
                    print(cdObject)
                }

                try? context.save()

                DispatchQueue.main.async {
                    database.performTask { context in
                        let objects = context.fetchAll(CD_MembershipPlan.self)
                        completion(objects)
                    }
                }
                
            }

        }, onError: {_ in 
            print("error")
        })
    }

    func deleteMembershipCard(id: String, completion: @escaping (Any) -> Void) {
        let url = RequestURL.deleteMembershipCard(cardId: id)
        let method = RequestHTTPMethod.delete
        
        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: EmptyResponse) in
            completion(response)
        }, onError: {
            print("error")
        })
    }
}
