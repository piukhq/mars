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
        
        // Tabs
        let loyaltyWallet = router.getLoyaltyWalletViewController()
        loyaltyWallet.tabBarItem = getTabBarLoyaltyButton()
        
        let add = router.getDummyViewControllerForAction()
        add.tabBarItem = getTabBarAddButton()
        
        let paymentWallet = router.getPaymentWalletViewController()
        paymentWallet.tabBarItem = getTabBarPaymentButton()
        
        childViewControllers.append(loyaltyWallet)
        childViewControllers.append(add)
        childViewControllers.append(paymentWallet)
    }
    
    func getTabBarLoyaltyButton() -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: "loyaltyInactive")?.withRenderingMode(.alwaysOriginal), tag: Buttons.loyaltyItem.rawValue)
        item.selectedImage = UIImage(named: "loyaltyActive")?.withRenderingMode(.alwaysOriginal)
        return item
    }
    
    func getTabBarAddButton() -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: "add")?.withRenderingMode(.alwaysOriginal), tag: Buttons.addItem.rawValue)
        item.imageInsets = UIEdgeInsets(top: 0.0, left: 0, bottom: 0, right: 0)
        return item
    }
    
    func getTabBarPaymentButton() -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: "paymentInactive")?.withRenderingMode(.alwaysOriginal), tag: Buttons.paymentItem.rawValue)
        item.selectedImage = UIImage(named: "paymentActive")?.withRenderingMode(.alwaysOriginal)
        item.isEnabled = false
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
