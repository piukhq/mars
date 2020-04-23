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
    private let apiClient: APIClient

    required init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func delete<T: WalletCard>(_ card: T, completion: EmptyCompletionBlock? = nil) {
        // Process the backend delete, but fail silently
        apiClient.performRequestWithNoResponse(onEndpoint: .paymentCard(cardId: card.id), using: .delete, parameters: nil, isUserDriven: false, completion: nil)

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
        if apiClient.isProduction {
            #if DEBUG
            fatalError("You are targetting production, but on a debug scheme. You should use a release scheme to test adding production payment cards.")
            #else
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
            #endif
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

        apiClient.performRequestWithParameters(onEndpoint: .spreedly, using: .post, parameters: spreedlyRequest, expecting: SpreedlyResponse.self, isUserDriven: true) { result in
            switch result {
            case .success(let response):
                onSuccess(response)
            case .failure(let error):
                onError(error)
            }
        }
    }

    private func createPaymentCard(_ paymentCard: PaymentCardCreateModel, spreedlyResponse: SpreedlyResponse? = nil, onSuccess: @escaping (CD_PaymentCard?) -> Void, onError: @escaping(Error?) -> Void) {

        guard let hash = SecureUtility.getPaymentCardHash(from: paymentCard) else {
            onError(nil)
            return
        }

        var paymentCreateRequest: PaymentCardCreateRequest?

        if let spreedlyResponse = spreedlyResponse {
            paymentCreateRequest = PaymentCardCreateRequest(spreedlyResponse: spreedlyResponse, hash: hash)
        } else {
            paymentCreateRequest = PaymentCardCreateRequest(model: paymentCard, hash: hash)
        }

        guard let request = paymentCreateRequest else {
            onError(nil)
            return
        }

        apiClient.performRequestWithParameters(onEndpoint: .paymentCards, using: .post, parameters: request, expecting: PaymentCardModel.self, isUserDriven: true) { result in
            switch result {
            case .success(let response):
                Current.database.performBackgroundTask { context in
                    let newObject = response.mapToCoreData(context, .update, overrideID: nil)

                    try? context.save()

                    DispatchQueue.main.async {
                        Current.database.performTask(with: newObject) { (context, safeObject) in
                            onSuccess(safeObject)
                        }
                    }
                }
            case .failure(let error):
                onError(error)
            }
        }
    }
}
