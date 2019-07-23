//
//  MainTabBarModels.swift
//  binkapp
//
//  Created by Paul Tiriteu on 22/07/2019.
//  Copyright (c) 2019 Bink. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum MainTabBar
{
  // MARK: Use cases
  
  enum Something
  {
    struct Request
    {
    }
    struct Response
    {
    }
    struct ViewModel
    {
        let childViewControllers = [
            LoyaltyWalletViewController(),
            AddCardViewController(),
            PaymentWalletViewController()
        ]
        
        func getTabBarLoyaltyButton() -> UITabBarItem {
            let item = UITabBarItem(title: nil, image: UIImage(named: "loyaltyActive")?.withRenderingMode(.alwaysOriginal), tag: 0)
            return item
        }
        
        func getTabBarAddButton() -> UITabBarItem {
            let item = UITabBarItem(title: nil, image: UIImage(named: "add")?.withRenderingMode(.alwaysOriginal), tag: 1)
            return item
        }
        
        func getTabBarPaymentButton() -> UITabBarItem {
            let item = UITabBarItem(title: nil, image: UIImage(named: "paymentInactive")?.withRenderingMode(.alwaysOriginal), tag: 2)
            return item
        }
    }
  }
}
