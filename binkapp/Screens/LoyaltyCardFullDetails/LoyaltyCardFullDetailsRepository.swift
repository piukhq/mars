//
//  LoyaltyCardFullDetailsRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class LoyaltyCardFullDetailsRepository: WalletRepository {
    private let apiClient: APIClient
    
    required init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func getPaymentCards(completion: @escaping ([PaymentCardModel]) -> Void) {
        let url = RequestURL.paymentCards
        let httpMethod = RequestHTTPMethod.get
        apiClient.doRequest(url: url, httpMethod: httpMethod, isUserDriven: false, onSuccess: { (results: [PaymentCardModel]) in
            completion(results)
        }) { (error) in }
    }

    func delete<T: WalletCard>(_ card: T, completion: EmptyCompletionBlock? = nil) {
        // Process the backend delete, but fail silently
        let url = RequestURL.membershipCard(cardId: card.id)
        let method = RequestHTTPMethod.delete
        apiClient.doRequest(url: url, httpMethod: method, isUserDriven: false, onSuccess: { (response: Nothing) in }, onError: { error in })

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
}
