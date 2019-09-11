//
//  LoyaltyWalletViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

protocol LoyaltyWalletViewModelDelegate {
//    func didFetchCards()
//    func didFetchMembershipPlans()
    func didFetchData()
}

class LoyaltyWalletViewModel {
    private let repository: LoyaltyWalletRepository
    private let router: MainScreenRouter
    private var membershipCards = [MembershipCardModel]()
    private var membershipPlans = [MembershipPlanModel]()
    private let dispatchGroup = DispatchGroup()
    
    var delegate: LoyaltyWalletViewModelDelegate?
    var membershipCardsCount: Int {
        return membershipCards.count
    }
    
    init(repository: LoyaltyWalletRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
        fetchMembershipCards()
    }
    
    // MARK: - Public methods
    
    func showDeleteConfirmationAlert(index: Int, yesCompletion: @escaping () -> Void, noCompletion: @escaping () -> Void) {
        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: {
            if let cardId = self.membershipCards[index].id {
                self.deleteMembershipCard(id: cardId, completion: {
                    self.membershipCards.remove(at: index)
                    yesCompletion()
                })
            }
        }, noCompletion: {
            noCompletion()
        })
    }
    
    func toBarcodeViewController(section: Int) {
        let card = membershipCards[section]
        guard let plan = getMembershipPlans().first(where: { $0.id == card.membershipPlan }) else { return }
        router.toBarcodeViewController(membershipPlan: plan, membershipCard: card)
    }
    
    func toFullDetailsCardScreen(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel) {
        router.toLoyaltyFullDetailsScreen(membershipCard: membershipCard, membershipPlan: membershipPlan)
    }
    
    func getMembershipCards() -> [MembershipCardModel] {
        return membershipCards
    }
    
    func membershipCard(forIndexPathSection section: Int) -> MembershipCardModel {
        return membershipCards[section]
    }
    
    func getMembershipPlans() -> [MembershipPlanModel] {
        return membershipPlans
    }
    
    func membershipPlan(forIndexPathSection section: Int) -> MembershipPlanModel {
        return membershipPlans[section]
    }
    
    func membershipPlanForCard(card: MembershipCardModel) -> MembershipPlanModel? {
        let planModelId = card.membershipPlan
        let memberhshipPlan = membershipPlans.first(where: {($0.id == planModelId)})
        return memberhshipPlan
    }
    
    func refreshScreen() {
        fetchMembershipCards()
    }
}

// MARK: Private methods

private extension LoyaltyWalletViewModel {
    func fetchMembershipCards() {
        dispatchGroup.enter()
        repository.getMembershipCards { (response) in
            self.membershipCards = response
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        repository.getMembershipPlans { (response) in
            self.membershipPlans = response
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(response) {
                let defaults = UserDefaults.standard
                defaults.set(encoded, forKey: "MembershipPlans")
            }
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.delegate?.didFetchData()
        }
    }
    
    func deleteMembershipCard(id: Int, completion: @escaping () -> Void) {
        repository.deleteMembershipCard(id: id) { _ in
            completion()
        }
    }
}
