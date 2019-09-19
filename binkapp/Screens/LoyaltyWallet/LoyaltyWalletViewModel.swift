//
//  LoyaltyWalletViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

protocol LoyaltyWalletViewModelDelegate {
    func loyaltyWalletViewModelDidFetchData(_ viewModel: LoyaltyWalletViewModel)
}

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

    func getMembershipCards(forceRefresh: Bool = false, completion: @escaping () -> Void) {
        repository.getMembershipCards(forceRefresh: forceRefresh) { [weak self] membershipCards in
            self?.membershipCards = membershipCards // self.membershipCards are correct here. all have properties
            completion()
        }
    }
    
    // MARK: - Public methods
    
//    func showDeleteConfirmationAlert(index: Int, yesCompletion: @escaping () -> Void, noCompletion: @escaping () -> Void) {
//        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: { [weak self] in
//            guard let strongSelf = self else {
//                return
//            }
//            let cardId = strongSelf.membershipCards[index].id
//            strongSelf.deleteMembershipCard(id: cardId, completion: {
//                strongSelf.membershipCards.remove(at: index)
//                yesCompletion()
//            })
//        }, noCompletion: {
//            noCompletion()
//        })
//    }
    
//    func toBarcodeViewController(section: Int) {
//        let card = membershipCards[section]
//        guard let planId = card.membershipPlan else {
//            return
//        }
//        guard let plan = getMembershipPlans().first(where: { $0.id == String(planId) }) else { return }
//        router.toBarcodeViewController(membershipPlan: plan, membershipCard: card)
//    }
    
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
        return membershipCards?[indexPath.section]
    }

    func membershipPlan(forIndexPath indexPath: IndexPath) -> CD_MembershipPlan? {
        return membershipPlans?[indexPath.section]
    }
    
    func membershipPlanForCard(card: CD_MembershipCard) -> CD_MembershipPlan? {
        return card.membershipPlan
    }
}

// MARK: Private methods

private extension LoyaltyWalletViewModel {
    
    func deleteMembershipCard(id: String, completion: @escaping () -> Void) {
        repository.deleteMembershipCard(id: id) { _ in
            completion()
        }
    }
}
