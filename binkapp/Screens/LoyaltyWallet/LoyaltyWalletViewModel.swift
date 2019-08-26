//
//  LoyaltyWalletViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

protocol LoyaltyWalletViewModelDelegate {
    func didFetchCards()
    func didFetchMembershipPlans()
}

class LoyaltyWalletViewModel {
    private let repository: LoyaltyWalletRepository
    private  let router: MainScreenRouter
    private var membershipCards = [MembershipCardModel]()
    private var membershipPlans = [MembershipPlanModel]()
    
    var delegate: LoyaltyWalletViewModelDelegate?
    
    init(repository: LoyaltyWalletRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
        fetchMembershipCards()
    }
    
    func deleteMembershipCard(id: Int, completion: @escaping () -> Void) {
        repository.deleteMembershipCard(id: id) { (response) in
            print(response)
            completion()
        }
    }
    
    func showDeleteConfirmationAlert(index: Int, yesCompletion: @escaping () -> Void, noCompletion: @escaping () -> Void) {
        router.showDeleteConfirmationAlert(yesCompletion: {
            self.deleteMembershipCard(id: index, completion: {
                self.membershipCards.remove(at: index)
                yesCompletion()
            })
        }, noCompletion: {
            noCompletion()
        })
    }
    
    func toBarcodeViewController() {
        router.toBarcodeViewController()
    }
    
    func getMemebershipCards() -> [MembershipCardModel] {
        return membershipCards
    }
    
    func getMembershipPlans() -> [MembershipPlanModel] {
        return membershipPlans
    }
    
    // MARK: Private methods
    
    private func fetchMembershipCards() {
        repository.getMembershipCards { (response) in
            self.membershipCards = response
            self.delegate?.didFetchCards()
        }
        repository.getMembershipPlans { (response) in
            self.membershipPlans = response
            self.delegate?.didFetchMembershipPlans()
        }
    }
}
