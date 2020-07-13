//
//  LoyaltyWalletRepository.swift
//  binkapp
//
//  Created by Nick Farrant on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct LoyaltyWalletRepository: WalletRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func delete<T: WalletCard>(_ card: T, completion: EmptyCompletionBlock? = nil) {
        // Process the backend delete, but fail silently
        let request = BinkNetworkRequest(endpoint: .membershipCard(cardId: card.id), method: .delete, headers: nil, isUserDriven: false)
        apiClient.performRequestWithNoResponse(request, parameters: nil, completion: nil)
        
        // Remove any stored credentials for points scraping
        Current.pointsScrapingManager.disableLocalPointsScraping(forMembershipCardId: card.id)

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
