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
    var navController: UINavigationController?
    
    init() {
        
    }
    
    func toMainScreen() {
        let repository = MainTabBarRepository()
        let viewModel = MainTabBarViewModel(repository: repository, router: self)
        let viewController = MainTabBarViewController(viewModel: viewModel)
        
        navController?.pushViewController(viewController, animated: true)
    }
    
    func getLoginScreen() -> UIViewController {
        let repository = LoginRepository()
        let viewModel = LoginViewModel(repository: repository, router: self)
        let viewController = LoginViewController(viewModel: viewModel)
        
        return viewController
    }
    
    func getNavigationControllerWithLoginScreen() -> UIViewController{
        navController = UINavigationController(rootViewController: getLoginScreen())
        navController?.setNavigationBarHidden(true, animated: true)
        return navController!
    }
    
    func getLoyaltyWalletViewController() -> UIViewController {
        let repository = LoyaltyWalletRepository()
        let viewModel = LoyaltyWalletViewModel(repository: repository, router: self)
        let viewController = LoyaltyWalletViewController(viewModel: viewModel)
        
        return viewController
    }
    
    func getAddCardViewController() -> UIViewController {
        return AddCardViewController()
    }
    
    func getPaymentWalletViewController() -> UIViewController {
        return PaymentWalletViewController()
    }
    
    func toLoyaltyWalletViewController() {
        navController?.pushViewController(getLoyaltyWalletViewController(), animated: true)
    }
    
    func showDeleteConfirmationAlert(completion: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to delete this card?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            completion()
        }))
        navController?.present(alert, animated: true, completion: nil)
    }
}
