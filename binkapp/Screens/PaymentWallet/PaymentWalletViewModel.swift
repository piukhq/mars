//
//  PaymentWalletViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PaymentWalletViewModel: WalletViewModel {
    typealias T = CD_PaymentCard
    typealias R = PaymentWalletRepository

    private let repository: R
    let router: MainScreenRouter

    init(repository: R, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }

    var cards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }

    func toCardDetail(for card: CD_PaymentCard) {
        router.toPaymentCardDetailViewController(paymentCard: card)
    }
}
