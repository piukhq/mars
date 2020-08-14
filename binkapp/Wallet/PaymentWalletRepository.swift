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
        var trackableCard = TrackableWalletCard()
        if let paymentCard = card as? CD_PaymentCard {
            trackableCard = TrackableWalletCard(uuid: paymentCard.uuid, loyaltyPlan: nil, paymentScheme: paymentCard.card?.paymentSchemeIdentifier)
        }
        
        BinkAnalytics.track(CardAccountAnalyticsEvent.deletePaymentCard(card: card))
        
        // Process the backend delete, but fail silently
        let request = BinkNetworkRequest(endpoint: .paymentCard(cardId: card.id), method: .delete, headers: nil, isUserDriven: false)
        apiClient.performRequestWithNoResponse(request, parameters: nil) { (success, _) in
            guard success else {
                BinkAnalytics.track(CardAccountAnalyticsEvent.deletePaymentCardResponseFail(card: trackableCard))
                return
            }
            BinkAnalytics.track(CardAccountAnalyticsEvent.deletePaymentCardResponseSuccess(card: trackableCard))
        }

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

    func addPaymentCard(_ paymentCard: PaymentCardCreateModel, onSuccess: @escaping (CD_PaymentCard?) -> Void, onError: @escaping(BinkError?) -> Void) {
        if apiClient.isProduction || apiClient.isPreProduction {
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

    private func requestSpreedlyToken(paymentCard: PaymentCardCreateModel, onSuccess: @escaping (SpreedlyResponse) -> Void, onError: @escaping (BinkError?) -> Void) {
        let spreedlyRequest = SpreedlyRequest(fullName: paymentCard.nameOnCard, number: paymentCard.fullPan, month: paymentCard.month, year: paymentCard.year)

        let request = BinkNetworkRequest(endpoint: .spreedly, method: .post, headers: nil, isUserDriven: true)
        apiClient.performRequestWithParameters(request, parameters: spreedlyRequest, expecting: SpreedlyResponse.self) { (result, _) in
            switch result {
            case .success(let response):
                onSuccess(response)
            case .failure(let error):
                onError(error)
            }
        }
    }

    private func createPaymentCard(_ paymentCard: PaymentCardCreateModel, spreedlyResponse: SpreedlyResponse? = nil, onSuccess: @escaping (CD_PaymentCard?) -> Void, onError: @escaping(BinkError?) -> Void) {

        let hash = SecureUtility.getPaymentCardHash(from: paymentCard)

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
        
        BinkAnalytics.track(CardAccountAnalyticsEvent.addPaymentCardRequest(request: paymentCard))

        let networkRequest = BinkNetworkRequest(endpoint: .paymentCards, method: .post, headers: nil, isUserDriven: true)
        apiClient.performRequestWithParameters(networkRequest, parameters: request, expecting: PaymentCardModel.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                Current.database.performBackgroundTask { context in
                    let newObject = response.mapToCoreData(context, .update, overrideID: nil)
                    
                    // The uuid will have already been set in the mapToCoreData call, but thats fine we can set it to the desired value here from the initial post request
                    newObject.uuid = paymentCard.uuid
                    
                    if let statusCode = rawResponse?.statusCode {
                        BinkAnalytics.track(CardAccountAnalyticsEvent.addPaymentCardResponseSuccess(request: paymentCard, paymentCard: newObject, statusCode: statusCode))
                    }

                    try? context.save()

                    DispatchQueue.main.async {
                        Current.database.performTask(with: newObject) { (context, safeObject) in
                            onSuccess(safeObject)
                        }
                    }
                }
            case .failure(let error):
                BinkAnalytics.track(CardAccountAnalyticsEvent.addPaymentCardResponseFail(request: paymentCard))
                onError(error)
            }
        }
    }
}
