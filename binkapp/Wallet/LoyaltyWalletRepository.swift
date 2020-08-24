//
//  LoyaltyWalletRepository.swift
//  binkapp
//
//  Created by Nick Farrant on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct LoyaltyWalletRepository: WalletServiceProtocol {
    func delete(_ membershipCard: CD_MembershipCard, completion: EmptyCompletionBlock? = nil) {
        var trackableCard = TrackableWalletCard()
        trackableCard = TrackableWalletCard(uuid: membershipCard.uuid, loyaltyPlan: membershipCard.membershipPlan?.id, paymentScheme: nil)
        
        BinkAnalytics.track(CardAccountAnalyticsEvent.deleteLoyaltyCard(card: membershipCard))
        
        deleteMembershipCard(membershipCard) { (success, _) in
            guard success else {
                BinkAnalytics.track(CardAccountAnalyticsEvent.deleteLoyaltyCardResponseFail(card: trackableCard))
                return
            }
            BinkAnalytics.track(CardAccountAnalyticsEvent.deleteLoyaltyCardResponseSuccess(card: trackableCard))
        }

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
