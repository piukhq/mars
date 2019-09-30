//
//  MainTabBarViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarViewModel {
    
    // MARK: - Helpers
    
    private struct Constants {
        static let iconInsets: CGFloat = 6.0
        static let centerInsets: CGFloat = 8.0
    }

    let router: MainScreenRouter
    
    var childViewControllers = [UIViewController]()
    
    init(router: MainScreenRouter) {
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
        item.title = "Loyalty"
        
        if #available(iOS 13, *) {
            item.imageInsets = UIEdgeInsets(top: Constants.iconInsets, left: 0, bottom: -Constants.iconInsets, right: 0)
        }
        
        return item
    }
    
    func getTabBarAddButton() -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: "add")?.withRenderingMode(.alwaysOriginal), tag: Buttons.addItem.rawValue)
        
        if #available(iOS 13, *) {
            item.imageInsets = UIEdgeInsets(top: Constants.centerInsets, left: 0, bottom: -Constants.centerInsets, right: 0)
        } else {
            item.imageInsets = UIEdgeInsets(top: Constants.iconInsets, left: 0, bottom: -Constants.iconInsets, right: 0)
        }
        
        return item
    }
    
    func getTabBarPaymentButton() -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: "paymentInactive")?.withRenderingMode(.alwaysOriginal), tag: Buttons.paymentItem.rawValue)
        item.selectedImage = UIImage(named: "paymentActive")?.withRenderingMode(.alwaysOriginal)
        item.title = "Payment"
        
        if #available(iOS 13, *) {
            item.imageInsets = UIEdgeInsets(top: Constants.iconInsets, left: 0, bottom: -Constants.iconInsets, right: 0)
        }
        
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
