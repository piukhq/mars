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
            Current.database.performBackgroundTask { context in
                let object = response.mapToCoreData(context, .update, overrideID: nil)

                try? context.save()

                DispatchQueue.main.async {
                    Current.database.performTask { context in
                        if let cdPaymentCard = context.fetchWithID(CD_PaymentCard.self, id: object.objectID) {
                            completion(cdPaymentCard)
                        }
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
            Current.database.performBackgroundTask { context in
                let object = response.mapToCoreData(context, .delta, overrideID: nil)

                try? context.save()

                DispatchQueue.main.async {
                    Current.database.performTask { context in
                        if let cdPaymentCard = context.fetchWithID(CD_PaymentCard.self, id: object.objectID) {
                            completion(cdPaymentCard)
                        }
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
