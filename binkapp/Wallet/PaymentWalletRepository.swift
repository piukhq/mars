//
//  PaymentWalletRepository.swift
//  binkapp
//
//  Created by Nick Farrant on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

class PaymentWalletRepository: PaymentWalletRepositoryProtocol {
    private let apiManager: ApiManager

    required init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }

    func delete<T: WalletCard>(_ card: T, completion: EmptyCompletionBlock? = nil) {
        // Process the backend delete, but fail silently
        let url = RequestURL.paymentCard(cardId: card.id)
        let method = RequestHTTPMethod.delete
        apiManager.doRequest(url: url, httpMethod: method, isUserDriven: false, onSuccess: { (response: EmptyResponse) in }, onError: { error in })

        // Process core data deletion
        Current.database.performBackgroundTask(with: card) { (context, cardToDelete) in
            if let cardToDelete = cardToDelete {
                context.delete(cardToDelete)
            }

            try? context.save()

            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    func addPaymentCard(_ paymentCard: PaymentCardCreateModel, onSuccess: @escaping (CD_PaymentCard?) -> Void, onError: @escaping(Error?) -> Void) {
        if apiManager.isProduction {
            requestSpreedlyToken(paymentCard: paymentCard, onSuccess: { [weak self] spreedlyResponse in
                guard spreedlyResponse.isValid else {
                    onError(nil)
                    return
                }

                self?.createPaymentCard(paymentCard, spreedlyResponse: spreedlyResponse, onSuccess: { createdPaymentCard in
                    onSuccess(createdPaymentCard)
                }, onError: { error in
                    onError(error)
                })
            }) { error in
                onError(error)
            }
            return
        } else {
            createPaymentCard(paymentCard, onSuccess: { createdPaymentCard in
                onSuccess(createdPaymentCard)
            }, onError: { error in
                onError(error)
            })
        }
    }

    private func requestSpreedlyToken(paymentCard: PaymentCardCreateModel, onSuccess: @escaping (SpreedlyResponse) -> Void, onError: @escaping (Error?) -> Void) {
        let spreedlyRequest = SpreedlyRequest(fullName: paymentCard.nameOnCard, number: paymentCard.fullPan, month: paymentCard.month, year: paymentCard.year)

        apiManager.doRequest(url: .spreedly, httpMethod: .post, parameters: spreedlyRequest, onSuccess: { (response: SpreedlyResponse) in
            onSuccess(response)
        }, onError: { error in
            onError(error)
        })
    }

    private func createPaymentCard(_ paymentCard: PaymentCardCreateModel, spreedlyResponse: SpreedlyResponse? = nil, onSuccess: @escaping (CD_PaymentCard?) -> Void, onError: @escaping(Error?) -> Void) {
        guard let paymentCreateRequest = PaymentCardCreateRequest(model: paymentCard, spreedlyResponse: spreedlyResponse) else {
            return
        }

        apiManager.doRequest(url: .paymentCards, httpMethod: .post, parameters: paymentCreateRequest, isUserDriven: true, onSuccess: { (response: PaymentCardModel) in
            Current.database.performBackgroundTask { context in
                let newObject = response.mapToCoreData(context, .update, overrideID: nil)

                try? context.save()

                DispatchQueue.main.async {
                    Current.database.performTask(with: newObject) { (context, safeObject) in
                        onSuccess(safeObject)
                    }
                }
            }
        }, onError: { error in
            onError(error)
        })
    }
}
