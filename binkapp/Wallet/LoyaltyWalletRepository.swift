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
    private let apiManager: ApiManager

    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }

    func delete<T: WalletCard>(_ card: T, completion: @escaping () -> Void) {
        // Process the backend delete, but fail silently
        let url = RequestURL.membershipCard(cardId: card.id)
        let method = RequestHTTPMethod.delete
        
        apiManager.doRequest(url: url, httpMethod: method, isUserDriven: false, onSuccess: { (response: EmptyResponse) in }, onError: { error in })

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
}
