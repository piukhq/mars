//
//  PaymentWalletRepository.swift
//  binkapp
//
//  Created by Nick Farrant on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

class PaymentWalletRepository: WalletServiceProtocol {
    func delete(_ paymentCard: CD_PaymentCard, completion: EmptyCompletionBlock? = nil) {
        var trackableCard = TrackableWalletCard()
        trackableCard = TrackableWalletCard(id: paymentCard.id, loyaltyPlan: nil, paymentScheme: paymentCard.card?.paymentSchemeIdentifier)
        
        BinkAnalytics.track(CardAccountAnalyticsEvent.deletePaymentCard(card: paymentCard))
        deletePaymentCard(paymentCard) { (success, _, responseData) in
            guard success else {
                BinkAnalytics.track(CardAccountAnalyticsEvent.deletePaymentCardResponseFail(card: trackableCard, responseData: responseData))
                if #available(iOS 14.0, *) {
                    BinkLogger.errorPrivate(PaymentCardLoggerError.deletePaymentCardFailure, value: paymentCard.id)
                    BinkLogger.error(PaymentCardLoggerError.deletePaymentCardFailure, value: responseData?.urlResponse?.statusCode.description)
                }
                return
            }
            BinkAnalytics.track(CardAccountAnalyticsEvent.deletePaymentCardResponseSuccess(card: trackableCard))
        }

        // Process core data deletion
        Current.database.performBackgroundTask(with: paymentCard) { (context, cardToDelete) in
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
        if Current.apiClient.isProduction || Current.apiClient.isPreProduction {
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

        getSpreedlyToken(withRequest: spreedlyRequest) { result in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    let paymentMethod = response.transaction?.paymentMethod
                    BinkLogger.infoPrivateHash(event: PaymentCardLoggerEvent.spreedlyTokenResponseSuccess, value: paymentMethod?.lastFour)
                }
                onSuccess(response)
            case .failure(let error):
                if #available(iOS 14.0, *) {
                    BinkLogger.error(PaymentCardLoggerError.spreedlyTokenResponseFailure, value: error.localizedDescription)
                }
                onError(error)
            }
        }
    }

    private func createPaymentCard(_ paymentCard: PaymentCardCreateModel, spreedlyResponse: SpreedlyResponse? = nil, onSuccess: @escaping (CD_PaymentCard?) -> Void, onError: @escaping(BinkError?) -> Void) {
        var paymentCreateRequest: PaymentCardCreateRequest?

        if let spreedlyResponse = spreedlyResponse {
            paymentCreateRequest = PaymentCardCreateRequest(spreedlyResponse: spreedlyResponse)
        } else {
            paymentCreateRequest = PaymentCardCreateRequest(model: paymentCard)
        }

        guard let request = paymentCreateRequest else {
            onError(nil)
            return
        }
        
        BinkAnalytics.track(CardAccountAnalyticsEvent.addPaymentCardRequest(request: paymentCard))
        addPaymentCard(withRequestModel: request) { (result, responseData) in
            switch result {
            case .success(let response):
                Current.database.performBackgroundTask { context in
                    let newObject = response.mapToCoreData(context, .update, overrideID: nil)
                    
                    // The uuid will have already been set in the mapToCoreData call, but thats fine we can set it to the desired value here from the initial post request
                    newObject.uuid = paymentCard.uuid
                    
                    if let statusCode = responseData?.urlResponse?.statusCode {
                        BinkAnalytics.track(CardAccountAnalyticsEvent.addPaymentCardResponseSuccess(request: paymentCard, paymentCard: newObject, statusCode: statusCode))
                    }
                    
                    try? context.save()
                    
                    DispatchQueue.main.async {
                        Current.database.performTask(with: newObject) { (_, safeObject) in
                            onSuccess(safeObject)
                        }
                    }
                }
            case .failure(let error):
                BinkAnalytics.track(CardAccountAnalyticsEvent.addPaymentCardResponseFail(request: paymentCard, responseData: responseData))
                if #available(iOS 14.0, *) {
                    BinkLogger.error(PaymentCardLoggerError.addPaymentCardFailure, value: responseData?.urlResponse?.statusCode.description)
                }
                onError(error)
            }
        }
    }
}
