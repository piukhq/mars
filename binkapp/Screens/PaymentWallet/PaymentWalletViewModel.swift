//
//  PaymentWalletViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PaymentWalletViewModel {
    private let repository: PaymentWalletRepository
    private let router: MainScreenRouter
    
    var paymentCards: [PaymentCardModel] = []
    
    init(repository: PaymentWalletRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }
}
