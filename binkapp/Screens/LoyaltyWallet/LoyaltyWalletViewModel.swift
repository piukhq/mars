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

    var joinCards: [JoinCard]? {
        return JoinCardFactory.makeJoinCards(forWallet: .loyalty)
    }

    var cards: [CD_MembershipCard]? {
        return Current.wallet.membershipCards
    }

    func toBarcodeViewController(item: Int, completion: @escaping () -> ()) {
        guard let card = cards?[item] else {
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

    func didSelectJoinCard(_ joinCard: JoinCard) {
        router.toAuthAndAddViewController(membershipPlan: joinCard.membershipPlan)
    }
}
