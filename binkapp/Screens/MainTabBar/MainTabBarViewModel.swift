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
