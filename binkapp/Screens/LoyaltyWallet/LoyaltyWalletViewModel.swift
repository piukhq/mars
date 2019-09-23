//
//  LoyaltyWalletViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit
import DeepDiff

protocol LoyaltyWalletViewModelDelegate {
    func loyaltyWalletViewModelDidFetchData(_ viewModel: LoyaltyWalletViewModel)
}

class LoyaltyWalletViewModel {
    private let repository: LoyaltyWalletRepository
    private let router: MainScreenRouter
    private var membershipCards: [CD_MembershipCard]?
    private var membershipPlans: [CD_MembershipPlan]?
    
    var delegate: LoyaltyWalletViewModelDelegate?
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
                self?.membershipCards = cards
                completion()
            }
        })
    }
    
    // MARK: - Public methods
    
    func showDeleteConfirmationAlert(index: Int, yesCompletion: @escaping ([MembershipCardModel]) -> (), noCompletion: @escaping () -> Void) {
        
//        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: {
//            if let cardId = self.membershipCards[index].id {
//                self.deleteMembershipCard(id: cardId, completion: {
//                    var new = self.membershipCards
//                    new.remove(at: index)
//                    yesCompletion(new)
//                })
//            }
//        }, noCompletion: {
//            DispatchQueue.main.async {
//                noCompletion()
//            }
//        })
    }
    
//    func updateMembershipCards(new: [MembershipCardModel]) {
//        membershipCards = new
//    }
    
    func toBarcodeViewController(item: Int, completion: @escaping () -> ()) {
        guard let card = membershipCards?[item] else { return }
        
        router.toBarcodeViewController(membershipCard: card, completion: completion)
//        guard let plan = getMembershipPlans().first(where: { $0.id == card.membershipPlan }) else { return }
    }
    
    func toFullDetailsCardScreen(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel) {
        router.toLoyaltyFullDetailsScreen(membershipCard: membershipCard, membershipPlan: membershipPlan)
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
    
    func deleteMembershipCard(id: String, completion: @escaping () -> Void) {
        repository.deleteMembershipCard(id: id) { _ in
            completion()
        }
    }
}
