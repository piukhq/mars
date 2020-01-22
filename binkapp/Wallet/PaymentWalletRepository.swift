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

    struct SpreedlyRequest: Codable {
        var paymentMethod: PaymentMethod?
        var retained: Bool?

        enum CodingKeys: String, CodingKey {
            case paymentMethod = "payment_method"
        }

        struct PaymentMethod: Codable {
            var creditCard: CreditCard?

            enum CodingKeys: String, CodingKey {
                case creditCard = "credit_card"
            }

            struct CreditCard: Codable {
                var number: String?
                var month: Int?
                var year: Int?
                var fullName: String?

                enum CodingKeys: String, CodingKey {
                    case number
                    case month
                    case year
                    case fullName = "full_name"
                }
            }
        }
    }

    struct SpreedlyResponse: Codable {
        var transaction: Transaction?

        struct Transaction: Codable {
            var paymentMethod: PaymentMethod?

            enum CodingKeys: String, CodingKey {
                case paymentMethod = "payment_method"
            }

            struct PaymentMethod: Codable {
                var token: String?
                var lastFour: String?
                var firstSix: String?
                var fingerprint: String?

                enum CodingKeys: String, CodingKey {
                    case token
                    case lastFour = "last_four_digits"
                    case firstSix = "first_six_digits"
                    case fingerprint
                }
            }
        }
    }

    func addPaymentCard(_ paymentCard: PaymentCardCreateModel, onSuccess: @escaping (CD_PaymentCard?) -> Void, onError: @escaping() -> Void) {
        if apiManager.isProduction {
            let spreedlyRequest = SpreedlyRequest(paymentMethod: SpreedlyRequest.PaymentMethod(creditCard: SpreedlyRequest.PaymentMethod.CreditCard(number: paymentCard.fullPan, month: paymentCard.month, year: paymentCard.year, fullName: paymentCard.nameOnCard)), retained: true)

            apiManager.doRequest(url: .spreedly, httpMethod: .post, parameters: spreedlyRequest, onSuccess: { (response: SpreedlyResponse) in
                // Success, make call to bink API
            }, onError: { error in
                print(error)
                onError()
            })
        }

        return

        guard let paymentCreateRequest = PaymentCardCreateRequest(model: paymentCard) else {
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
            print(error)
            onError()
        })
    }
}
