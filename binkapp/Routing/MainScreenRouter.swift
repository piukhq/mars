//
//  MainScreenRouter.swift
//  binkapp
//
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
        return LoyaltyWalletViewController()
    }
    
    func getAddCardViewController() -> UIViewController {
        return AddCardViewController()
    }
    
    func getPaymentWalletViewController() -> UIViewController {
        return PaymentWalletViewController()
    }
}
