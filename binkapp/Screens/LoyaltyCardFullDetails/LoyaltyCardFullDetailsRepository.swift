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
        var trackableCard = TrackableWalletCard()
        if let loyaltyCard = card as? CD_MembershipCard {
            trackableCard = TrackableWalletCard(uuid: loyaltyCard.uuid, loyaltyPlan: loyaltyCard.membershipPlan?.id, paymentScheme: nil)
        }
        
        BinkAnalytics.track(CardAccountAnalyticsEvent.deleteLoyaltyCard(card: card))
        
        // Process the backend delete, but fail silently
        let request = BinkNetworkRequest(endpoint: .membershipCard(cardId: card.id), method: .delete, headers: nil, isUserDriven: false)
        apiClient.performRequestWithNoResponse(request, parameters: nil) { (success, _) in
            guard success else {
                BinkAnalytics.track(CardAccountAnalyticsEvent.deleteLoyaltyCardResponseFail(card: trackableCard))
                return
            }
            BinkAnalytics.track(CardAccountAnalyticsEvent.deleteLoyaltyCardResponseSuccess(card: trackableCard))
        }
        
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
