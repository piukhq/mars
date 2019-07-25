//
//  MainScreenRouter.swift
//  binkapp
//
//  Created by Paul Tiriteu on 25/07/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class MainScreenRouter {
    init() {
        
    }
    
    func getMainScreen() -> UIViewController {
        let repository = MainTabBarRepository()
        let viewModel = MainTabBarViewModel(repository: repository, router: self)
        let viewController = MainTabBarViewController(viewModel: viewModel)
        
        return viewController
    }
    
    func getLoyaltyWalletViewController() -> UIViewController {
        let repository = LoyaltyWalletRepository()
        let viewModel = LoyaltyWalletViewModel(repository: repository)
        let viewController = LoyaltyWalletViewController(viewModel: viewModel)
        
        return viewController
    }
    
    func getAddCardViewController() -> UIViewController {
        return AddCardViewController()
    }
    
    func getPaymentWalletViewController() -> UIViewController {
        return PaymentWalletViewController()
    }
}
