//
//  LoyaltyWalletViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit
import DeepDiff

class LoyaltyWalletViewModel {
    private let repository: LoyaltyWalletRepository
    private let router: MainScreenRouter
    private var membershipCards: [CD_MembershipCard]?
    private var membershipPlans: [CD_MembershipPlan]?
    
    var membershipCardsCount: Int {
        return membershipCards?.count ?? 0
    }
    
    init(repository: LoyaltyWalletRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }

    func getWallet(forceRefresh: Bool = false, completion: @escaping () -> Void) {
        repository.getMembershipPlans(forceRefresh: forceRefresh, completion: { plans in
            self.repository.getMembershipCards(forceRefresh: forceRefresh) { [weak self] cards in
                self?.membershipCards = cards ?? []
                completion()
            }
        })
    }
    
    // MARK: - Public methods
    
    func showDeleteConfirmationAlert(card: CD_MembershipCard, yesCompletion: @escaping () -> (), noCompletion: @escaping () -> Void) {
        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: {
            let cardId = card.id
            self.deleteMembershipCard(card, completion: {
                self.membershipCards?.removeAll(where: { $0.id == cardId })
                yesCompletion()
            })
        }, noCompletion: {
            DispatchQueue.main.async {
                noCompletion()
            }
        })
    }
    
    func toBarcodeViewController(item: Int, completion: @escaping () -> ()) {
        guard let card = membershipCards?[item] else { return }
        
        router.toBarcodeViewController(membershipCard: card, completion: completion)
    }
    
    func toFullDetailsCardScreen(membershipCard: CD_MembershipCard) {
        router.toLoyaltyFullDetailsScreen(membershipCard: membershipCard)
    }
    
    func getMembershipCards() -> [CD_MembershipCard]? {
        return membershipCards
    }

    func getMembershipPlans() -> [CD_MembershipPlan]? {
        return membershipPlans
    }

    func membershipCard(forIndexPath indexPath: IndexPath) -> CD_MembershipCard? {
        return membershipCards?[indexPath.item]
    }

    func membershipPlan(forIndexPath indexPath: IndexPath) -> CD_MembershipPlan? {
        return membershipPlans?[indexPath.item]
    }
    
//    func membershipPlanForCard(card: CD_MembershipCard) -> CD_MembershipPlan? {
//        guard let planId = card.membershipPlan?.intValue else {
//            return nil
//        }
//        let planIdString = String(planId)
//        return membershipPlans?.first(where: { $0.id == planIdString })
//    }
}

// MARK: Private methods

private extension LoyaltyWalletViewModel {
    
    func deleteMembershipCard(_ card: CD_MembershipCard, completion: @escaping () -> Void) {
        // Process the backend delete, but fail silently
        repository.deleteMembershipCard(id: card.id) { _ in }
        
        Current.database.performBackgroundTask(with: card) { (context, cardToDelete) in
            if let cardToDelete = cardToDelete { context.delete(cardToDelete) }
            try? context.save()
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
