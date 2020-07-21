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

    func delete<T: WalletCard>(_ card: T, completion: EmptyCompletionBlock? = nil) {
        // Process the backend delete, but fail silently
        let request = BinkNetworkRequest(endpoint: .membershipCard(cardId: card.id), method: .delete, headers: nil, isUserDriven: false)
        apiClient.performRequestWithNoResponse(request, body: nil, completion: nil)

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
