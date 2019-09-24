//
//  PaymentWalletViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

protocol PaymentWalletViewModelDelegate: class {
    func paymentWalletViewModelDidLoadData(_ viewModel: PaymentWalletViewModel)
}

class PaymentWalletViewModel {
    private let repository: PaymentWalletRepository
    private let router: MainScreenRouter
    
    weak var delegate: PaymentWalletViewModelDelegate?
    private var paymentCards: [PaymentCardModel]?
    
    init(repository: PaymentWalletRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }
    
    func getWallet() {
        repository.getPaymentCards { [weak self] cards in
            self?.paymentCards = cards
        }
    }

    func getPaymentCards() -> [PaymentCardModel]? {
        return paymentCards
    }
}
