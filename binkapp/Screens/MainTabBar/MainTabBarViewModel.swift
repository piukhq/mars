//
//  MainTabBarViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 25/07/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarViewModel {
    
    let repository: MainTabBarRepository
    let router: MainScreenRouter
    
    let childViewControllers: [UIViewController] = [
//        LoyaltyWalletViewController(),
//        AddCardViewController(),
//        PaymentWalletViewController()
    ]
    
    init(repository: MainTabBarRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }
    
    func getTabBarLoyaltyButton() -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: "loyaltyInactive")?.withRenderingMode(.alwaysOriginal), tag: Buttons.loyaltyItem.rawValue)
        item.selectedImage = UIImage(named: "loyaltyActive")?.withRenderingMode(.alwaysOriginal)
        return item
    }
    
    func getTabBarAddButton() -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: "add")?.withRenderingMode(.alwaysOriginal), tag: Buttons.addItem.rawValue)
        return item
    }
    
    func getTabBarPaymentButton() -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: "paymentInactive")?.withRenderingMode(.alwaysOriginal), tag: Buttons.paymentItem.rawValue)
        item.selectedImage = UIImage(named: "paymentActive")?.withRenderingMode(.alwaysOriginal)
        return item
    }
}

enum Buttons: Int {
    case loyaltyItem
    case addItem
    case paymentItem
    
    func getIntegerValue() -> Int {
        switch self {
        case .loyaltyItem: return self.rawValue
        case .addItem: return self.rawValue
        case .paymentItem: return self.rawValue
        }
    }
}
