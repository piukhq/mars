//
//  LoyaltyCardFullDetailsRepository.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

typealias EmptyCompletionBlock = () -> Void

// TODO: This should be reusable code whether in LCD or wallet
class LoyaltyCardFullDetailsRepository: WalletServiceProtocol {
    func delete(_ membershipCard: CD_MembershipCard, completion: EmptyCompletionBlock? = nil) {
        deleteMembershipCard(membershipCard, completion: nil)
        
        // Process core data deletion
        Current.database.performBackgroundTask(with: membershipCard) { (context, cardToDelete) in
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
