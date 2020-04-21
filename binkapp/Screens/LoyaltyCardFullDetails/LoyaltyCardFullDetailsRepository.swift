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
    
    func getPaymentCards(completion: @escaping ([PaymentCardModel]?) -> Void) {
        apiClient.performRequest(onEndpoint: .paymentCards, using: .get, expecting: [PaymentCardModel].self, isUserDriven: false) { result in
            switch result {
            case .success(let paymentCards):
                completion(paymentCards)
            case .failure:
                completion(nil)
            }
        }
    }

    func delete<T: WalletCard>(_ card: T, completion: EmptyCompletionBlock? = nil) {
        // Process the backend delete, but fail silently
        apiClient.performRequest(onEndpoint: .membershipCard(cardId: card.id), using: .delete, expecting: Nothing.self, isUserDriven: false, completion: nil)

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
