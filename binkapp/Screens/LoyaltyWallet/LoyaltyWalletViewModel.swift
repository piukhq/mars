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
    private var membershipCards = [MembershipCardModel]()
    private var membershipPlans = [MembershipPlanModel]()
    
    var delegate: LoyaltyWalletViewModelDelegate?
    var membershipCardsCount: Int {
        return membershipCards.count
    }
    
    init(repository: LoyaltyWalletRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
        fetchData()
    }
    
    // MARK: - Public methods
    
    func showDeleteConfirmationAlert(index: Int, yesCompletion: @escaping ([MembershipCardModel]) -> (), noCompletion: @escaping () -> Void) {
        
        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: {
            if let cardId = self.membershipCards[index].id {
                self.deleteMembershipCard(id: cardId, completion: {
                    var new = self.membershipCards
                    new.remove(at: index)
                    yesCompletion(new)
                })
            }
        }, noCompletion: {
            DispatchQueue.main.async {
                noCompletion()
            }
        })
    }
    
    func updateMembershipCards(new: [MembershipCardModel]) {
        membershipCards = new
    }
    
    func toBarcodeViewController(item: Int, completion: @escaping () -> ()) {
        let card = membershipCards[item]
        guard let plan = getMembershipPlans().first(where: { $0.id == card.membershipPlan }) else { return }
        router.toBarcodeViewController(membershipPlan: plan, membershipCard: card, completion: completion)
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
    
    @objc func refreshScreen() {
        fetchData()
    }
}

// MARK: Private methods

private extension LoyaltyWalletViewModel {
    func fetchData() {
        repository.getMembershipCards { [weak self] (response) in
            guard let wself = self else { return }
            wself.membershipCards = response
            wself.repository.getMembershipPlans { (response) in
                wself.membershipPlans = response
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(response) {
                    let defaults = UserDefaults.standard
                    defaults.set(encoded, forKey: "MembershipPlans")
                }
                wself.delegate?.loyaltyWalletViewModelDidFetchData(wself)
            }
        }
    }

    
    func deleteMembershipCard(id: Int, completion: @escaping () -> Void) {
        repository.deleteMembershipCard(id: id) { _ in
            completion()
        }
    }
}


