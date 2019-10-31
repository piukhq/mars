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

    func delete<T: WalletCard>(_ card: T, completion: @escaping () -> Void) {
        // Process the backend delete, but fail silently
        let url = RequestURL.deletePaymentCard(cardId: card.id)
        let method = RequestHTTPMethod.delete
        apiManager.doRequest(url: url, httpMethod: method, onSuccess: { (response: EmptyResponse) in }, onError: { error in })

        // Process core data deletion
        Current.database.performBackgroundTask(with: card) { (context, cardToDelete) in
            if let cardToDelete = cardToDelete {
                context.delete(cardToDelete)
            }

            try? context.save()

            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func addPaymentCard(_ paymentCard: PaymentCardCreateModel, completion: @escaping (Bool) -> Void) {
        guard let paymentCreateRequest = PaymentCardCreateRequest(model: paymentCard) else {
            return
        }

        try? apiManager.doRequest(url: .paymentCards, httpMethod: .post, parameters: paymentCreateRequest.asDictionary(), onSuccess: { [weak self] (response: PaymentCardResponse) in
//            guard let self = self else { return }

            // Create local payment card
            // the response is PaymentCardResponse
            // We have a paymentcardcardreponse type already mapping to core data, can we use that?
//            self.mapCoreDataObjects(objectsToMap: [response], type: CD_PaymentCard.self) {
//                //
//            }

            completion(true)
        }, onError: { error in
            print(error)
            completion(false)
        })
    }
}
