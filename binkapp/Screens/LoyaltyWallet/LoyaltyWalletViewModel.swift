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
    var membershipCards = [Any]()
    
    init(repository: LoyaltyWalletRepository) {
        self.repository = repository
    }
    
    func getMembershipCards() {
        repository.getMembershipCards { (response) in
            print(response)
        }
    }
    
    func deleteMembershipCard(id: Int, completion: @escaping () -> Void) {
        repository.deleteMembershipCard(id: id) { (response) in
            print(response)
        }
    }
}
