//
//  LoyaltyWalletViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 25/07/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class LoyaltyWalletViewModel {
    let repository: LoyaltyWalletRepository
    
    init(repository: LoyaltyWalletRepository) {
        self.repository = repository
    }
}
