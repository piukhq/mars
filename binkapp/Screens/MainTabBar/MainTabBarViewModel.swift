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
    
    private enum Constants {
        static let iconInsets: CGFloat = 6.0
        static let centerInsets: CGFloat = 8.0
    }

    init() {
        configure()
    }
    
    var viewControllers: [UIViewController] = []
    
    private func configure() {
        // LOYALTY WALLET
        let loyaltyWalletViewModel = LoyaltyWalletViewModel()
        let loyaltyWalletViewController = LoyaltyWalletViewController(viewModel: loyaltyWalletViewModel)
        let loyaltyWalletNavigationController = PortraitNavigationController(rootViewController: loyaltyWalletViewController)
        loyaltyWalletNavigationController.tabBarItem = getTabBarLoyaltyButton()
        
        // ADD OPTIONS
        let addOptionsViewController = AddingOptionsTabBarViewController()
        addOptionsViewController.tabBarItem = getTabBarAddButton()
        
        // PAYMENT WALLET
        let paymentWalletViewModel = PaymentWalletViewModel()
        let paymentWalletViewController = PaymentWalletViewController(viewModel: paymentWalletViewModel)
        let paymentWalletNavigationController = PortraitNavigationController(rootViewController: paymentWalletViewController)
        paymentWalletNavigationController.tabBarItem = getTabBarPaymentButton()
        
        viewControllers = [loyaltyWalletNavigationController, addOptionsViewController, paymentWalletNavigationController]
    }
    
    private func getTabBarLoyaltyButton() -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: "loyaltyInactive"), tag: Buttons.loyaltyItem.rawValue)
        item.selectedImage = UIImage(named: "loyaltyActive")
        item.title = "Loyalty"
        
        if #available(iOS 13, *) {
            item.imageInsets = UIEdgeInsets(top: Constants.iconInsets, left: 0, bottom: -Constants.iconInsets, right: 0)
        }
        
        return item
    }
    
    private func getTabBarAddButton() -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: "add"), tag: Buttons.addItem.rawValue)
        
        if #available(iOS 13, *) {
            item.imageInsets = UIEdgeInsets(top: Constants.centerInsets, left: 0, bottom: -Constants.centerInsets, right: 0)
        } else {
            item.imageInsets = UIEdgeInsets(top: Constants.iconInsets, left: 0, bottom: -Constants.iconInsets, right: 0)
        }
        
        return item
    }
    
    private func getTabBarPaymentButton() -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: "paymentInactive"), tag: Buttons.paymentItem.rawValue)
        item.selectedImage = UIImage(named: "paymentActive")
        item.title = "Payment"
        
        if #available(iOS 13, *) {
            item.imageInsets = UIEdgeInsets(top: Constants.iconInsets, left: 0, bottom: -Constants.iconInsets, right: 0)
        }
        
        return item
    }
    
    func toAddingOptionsScreen() {
        let viewController = ViewControllerFactory.makeAddingOptionsViewController()
        let navigationRequest = ModalNavigationRequest(viewController: viewController, fullScreen: true, embedInNavigationController: false, transition: .crossDissolve)
        Current.navigate.to(navigationRequest)
    }
}

enum Buttons: Int {
    case loyaltyItem = 0
    case paymentItem
    case addItem
}
