//
//  MainTabBarViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarViewModel {
    
    let repository: MainTabBarRepository
    let router: MainScreenRouter
    
    var childViewControllers = [UIViewController]()
    
    init(repository: MainTabBarRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
        childViewControllers.append(router.getLoyaltyWalletViewController())
        childViewControllers.append(router.getPaymentWalletViewController())
    }
    
    func getTabBarLoyaltyButton() -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: "loyaltyInactive"), tag: Buttons.loyaltyItem.rawValue)
        item.selectedImage = UIImage(named: "loyaltyActive")
        return item
    }
    
    func getTabBarAddButton() -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: "add"), tag: Buttons.addItem.rawValue)
        return item
    }
    
    func getTabBarPaymentButton() -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: "paymentInactive"), tag: Buttons.paymentItem.rawValue)
        item.selectedImage = UIImage(named: "paymentActive")
        return item
    }
    
    func toAddingOptionsScreen() {
        router.toAddingOptionsViewController()
    }
    
    func toSettingsScreen() {
        router.toSettingsScreen()
    }
    
    func toDebugMenu() {
        router.toDebugMenu()
    }
}

enum Buttons: Int {
    case loyaltyItem = 0
    case paymentItem
    case addItem
}
