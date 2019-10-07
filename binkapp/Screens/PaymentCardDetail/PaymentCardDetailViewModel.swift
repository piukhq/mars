//
//  PaymentCardDetailViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 03/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PaymentCardDetailViewModel {
    private let paymentCard: CD_PaymentCard
    private let router: MainScreenRouter

    init(paymentCard: CD_PaymentCard, router: MainScreenRouter) {
        self.paymentCard = paymentCard
        self.router = router
    }

    var paymentCardCellViewModel: PaymentCardCellViewModel {
        return PaymentCardCellViewModel(paymentCard: paymentCard, router: router)
    }
}
