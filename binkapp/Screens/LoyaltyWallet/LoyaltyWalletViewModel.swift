//
//  LoyaltyWalletViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit
import DeepDiff
import CoreData

class LoyaltyWalletViewModel: WalletViewModel {
    typealias T = CD_MembershipCard
    typealias R = LoyaltyWalletRepository

    private let repository: R
    private let router: MainScreenRouter

    required init(repository: R, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }

    var walletPrompts: [WalletPrompt]? {
        return WalletPromptFactory.makeWalletPrompts(forWallet: .loyalty)
    }
    
    var cards: [CD_MembershipCard]? {
         return Current.wallet.membershipCards
     }

    func toBarcodeViewController(indexPath: IndexPath, completion: @escaping () -> ()) {
        guard let card = card(forIndexPath: indexPath) else {
            return
        }
        
        router.toBarcodeViewController(membershipCard: card, completion: completion)
    }

    func toCardDetail(for card: CD_MembershipCard) {
        router.toLoyaltyFullDetailsScreen(membershipCard: card)
    }

    func showDeleteConfirmationAlert(card: CD_MembershipCard, yesCompletion: @escaping () -> Void, noCompletion: @escaping () -> Void) {
        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: { [weak self] in
            self?.repository.delete(card, completion: yesCompletion)
        }, noCompletion: {
            DispatchQueue.main.async {
                noCompletion()
            }
        })
    }

    func didSelectWalletPrompt(_ walletPrompt: WalletPrompt) {
        switch walletPrompt.type {
        case .loyaltyJoin(let membershipPlan):
            router.toAddOrJoinViewController(membershipPlan: membershipPlan)
        case .addPaymentCards:
            router.toAddPaymentViewController()
        }

    }
}
