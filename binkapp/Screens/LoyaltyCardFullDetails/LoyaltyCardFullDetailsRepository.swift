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
        let trackableCard = TrackableWalletCard(id: membershipCard.id, loyaltyPlan: membershipCard.membershipPlan?.id, paymentScheme: nil)
        
        BinkAnalytics.track(CardAccountAnalyticsEvent.deleteLoyaltyCard(card: membershipCard))
        
        deleteMembershipCard(membershipCard) { (success, _, responseData) in
            guard success else {
                BinkAnalytics.track(CardAccountAnalyticsEvent.deleteLoyaltyCardResponseFail(card: trackableCard, responseData: responseData))
                if #available(iOS 14.0, *) {
                    BinkLogger.errorPrivate(.deleteLoyaltyCardFailure, value: "\(membershipCard.id ?? "") - \(responseData?.urlResponse?.statusCode.description ?? "")", category: .loyaltyCardFullDetailsRepository)
                }
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
