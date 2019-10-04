//
//  PaymentWalletViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PaymentWalletViewModel {
    let router: MainScreenRouter

    private var paymentCards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }
    
    init(router: MainScreenRouter) {
        self.router = router
    }

    var paymentCardCount: Int {
        return paymentCards?.count ?? 0
    }

    func paymentCardAtIndexPath(_ indexPath: IndexPath) -> CD_PaymentCard? {
        return paymentCards?[indexPath.row]
    }

    func loadWallet() {
        Current.wallet.refresh()
    }
}
