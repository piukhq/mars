//
//  WalletCard.swift
//  binkapp
//
//  Created by Nick Farrant on 10/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

/// A base protocol for any card object that could be present in a wallet, such as a loyalty card, a payment card or a join card
protocol WalletCard {
    var type: WalletCardType { get }
}

enum WalletCardType {
    case loyalty
    case payment
    case join
    case prompt // e.g. add your payment cards prompt
}
