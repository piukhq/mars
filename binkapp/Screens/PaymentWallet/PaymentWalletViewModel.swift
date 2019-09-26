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

    var paymentCards: [PaymentCardModel]?
    
    init(repository: PaymentWalletRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }
    
    func getWallet(forceRefresh: Bool = false, completion: @escaping () -> Void) {
        repository.getPaymentCards { [weak self] cards in
            self?.paymentCards = cards
            completion()
        }
    }
}
