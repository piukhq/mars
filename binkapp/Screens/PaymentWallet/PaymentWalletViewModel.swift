//
//  PaymentWalletViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PaymentWalletViewModel {
    private let repository: PaymentWalletRepository
    let router: MainScreenRouter

    private var paymentCards: [CD_PaymentCard]?
    
    init(repository: PaymentWalletRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }
    
    func getWallet(forceRefresh: Bool = false, completion: @escaping () -> Void) {
        repository.getPaymentCards(forceRefresh: forceRefresh) { [weak self] cards in
            self?.paymentCards = cards
            completion()
        }
    }

    var paymentCardCount: Int {
        return paymentCards?.count ?? 0
    }

    func paymentCardAtIndexPath(_ indexPath: IndexPath) -> CD_PaymentCard? {
        return paymentCards?[indexPath.row]
    }

    func toPaymentCardDetail(for paymentCard: CD_PaymentCard) {
        router.toPaymentCardDetailViewController(paymentCard: paymentCard)
    }
}
