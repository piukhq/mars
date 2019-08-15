//
//  LoyaltyWalletViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 25/07/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class LoyaltyWalletViewModel {
    let repository: LoyaltyWalletRepository
    let router: MainScreenRouter
    
    var membershipCards = [Any]()
    
    var items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    init(repository: LoyaltyWalletRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }
    
    func getMembershipCards() {
        repository.getMembershipCards { (response) in
            self.membershipCards = response
            print(response)
        }
    }
    
    func deleteMembershipCard(id: Int, completion: @escaping () -> Void) {
        repository.deleteMembershipCard(id: id) { (response) in
            print(response)
            completion()
        }
    }
    
    func showDeleteConfirmationAlert(section: Int, yesCompletion: @escaping () -> Void, noCompletion: @escaping () -> Void) {
//        router.showDeleteConfirmationAlert {
//            self.deleteMembershipCard(id: section, completion: {
//                self.items.remove(at: section)
//                completion()
//            })
//        }
        router.showDeleteConfirmationAlert(yesCompletion: {
            self.deleteMembershipCard(id: section, completion: {
                self.items.remove(at: section)
                yesCompletion()
            })
        }, noCompletion: {
            noCompletion()
        })
    }
    
    func toBarcodeViewController() {
        router.toBarcodeViewController()
    }
}
