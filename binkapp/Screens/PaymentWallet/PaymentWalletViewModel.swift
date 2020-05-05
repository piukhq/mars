//
//  PaymentWalletViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PaymentWalletViewModel: WalletViewModel {
    typealias T = CD_PaymentCard
    typealias R = PaymentWalletRepository

    private let repository: R
    let router: MainScreenRouter

    required init(repository: R, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }

    var walletPrompts: [WalletPrompt]? {
        return WalletPromptFactory.makeWalletPrompts(forWallet: .payment)
    }

    var cards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }

    func toCardDetail(for card: CD_PaymentCard) {
        router.toPaymentCardDetailViewController(paymentCard: card)
    }

    func didSelectWalletPrompt(_ walletPrompt: WalletPrompt) {
        switch walletPrompt.type {
        case .addPaymentCards:
            router.toAddPaymentViewController()
        default:
            return
        }
    }

    func showDeleteConfirmationAlert(card: CD_PaymentCard, yesCompletion: @escaping () -> Void, noCompletion: @escaping () -> Void) {
        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: { [weak self] in
            guard Current.apiClient.networkIsReachable else {
                self?.router.presentNoConnectivityPopup()
                noCompletion()
                return
            }
            self?.repository.delete(card, completion: yesCompletion)
        }, noCompletion: {
            DispatchQueue.main.async {
                noCompletion()
            }
        })
    }
}
