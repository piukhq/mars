//
//  PaymentCardDetailRepository.swift
//  binkapp
//
//  Created by Nick Farrant on 08/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PaymentCardDetailRepository {
    private let apiManager: ApiManager

    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }

    func getPaymentCard(forId id: String, completion: @escaping (CD_PaymentCard?) -> Void) {
        let url = RequestURL.paymentCard(cardId: id)
        let method = RequestHTTPMethod.get

        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: PaymentCardModel) in
            Current.database.performBackgroundTask { backgroundContext in
                let newObject = response.mapToCoreData(backgroundContext, .update, overrideID: nil)
                let newObjectId = newObject.id ?? ""

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

    func linkMembershipCard(withId membershipCardId: String, toPaymentCardWithId paymentCardId: String, completion: @escaping (CD_PaymentCard?) -> Void) {
        let url = RequestURL.linkMembershipCardToPaymentCard(membershipCardId: membershipCardId, paymentCardId: paymentCardId)
        let method: RequestHTTPMethod = .patch

        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: PaymentCardModel) in
            Current.database.performBackgroundTask { backgroundContext in
                // Should we be using .none here? Only option that works...
                let newObject = response.mapToCoreData(backgroundContext, .none, overrideID: nil)
                let newObjectId = newObject.id ?? ""

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
