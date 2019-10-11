//
//  PLLScreenRepository.swift
//  binkapp
//
//  Created by Pop Dorin on 11/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLLScreenRepository {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func linkMembershipCard(withId membershipCardId: String, toPaymentCardWithId paymentCardId: String, completion: @escaping (CD_PaymentCard?) -> Void) {
        let url = RequestURL.linkMembershipCardToPaymentCard(membershipCardId: membershipCardId, paymentCardId: paymentCardId)
        let method: RequestHTTPMethod = .patch
        
        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: PaymentCardModel) in
            Current.database.performBackgroundTask { backgroundContext in
                // TODO: Should we be using .none here? Only option that works...
                // It's functional but we're not sure why it doesn't work otherwise and that is concerning.
                let newObject = response.mapToCoreData(backgroundContext, .none, overrideID: nil)
                guard let newObjectId = newObject.id else {
                    fatalError("Failed to get the id from the new object.")
                }
                
                try? backgroundContext.save()
                
                DispatchQueue.main.async {
                    Current.database.performTask { context in
                        let fetchedObject = context.fetchWithApiID(CD_PaymentCard.self, id: newObjectId)
                        completion(fetchedObject)
                    }
                }
            }
        }, onError: { _ in
            completion(nil)
        })
    }
    
    func removeLinkToMembershipCard(_ membershipCard: CD_MembershipCard, forPaymentCard paymentCard: CD_PaymentCard, completion: @escaping () -> Void) {
        let url = RequestURL.linkMembershipCardToPaymentCard(membershipCardId: membershipCard.id, paymentCardId: paymentCard.id)
        let method: RequestHTTPMethod = .delete
        
        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: PaymentCardModel) in
            Current.database.performBackgroundTask { context in
                paymentCard.removeLinkedMembershipCardsObject(membershipCard)
                
                try? context.save()
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }, onError: { _ in
            completion()
        })
    }
}
