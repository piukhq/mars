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
    var paymentCards: [PaymentCardModel] = []
    
    init(repository: PaymentWalletRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }
    
    func getPaymentCards() {
        repository.getPaymentCards { [weak self] (results) in
            guard let wself = self else { return }
            wself.paymentCards = results
            wself.delegate?.paymentWalletViewModelDidLoadData(wself)
        }
    }
}
