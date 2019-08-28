//
//  MainScreenRouter.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class MainScreenRouter {
    var navController: UINavigationController?
    
    let apiManager = ApiManager()

    func toMainScreen() {
        let repository = MainTabBarRepository()
        let viewModel = MainTabBarViewModel(repository: repository, router: self)
        let viewController = MainTabBarViewController(viewModel: viewModel)

        navController?.pushViewController(viewController, animated: true)
    }
    
    func getNavigationControllerWithLoginScreen() -> UIViewController{
        navController = UINavigationController(rootViewController: getLoginScreen())
        navController?.navigationBar.isTranslucent = false
        
        return navController!
    }
    
    func getLoginScreen() -> UIViewController {
        let repository = LoginRepository()
        let viewModel = LoginViewModel(repository: repository, router: self)
        let viewController = LoginViewController(viewModel: viewModel)
        
        return viewController
    }
    
    func toSettingsScreen() {
        print("settings button pressed")
    }
    
    func getLoyaltyWalletViewController() -> UIViewController {
        let repository = LoyaltyWalletRepository(apiManager: apiManager)
        let viewModel = LoyaltyWalletViewModel(repository: repository, router: self)
        let viewController = LoyaltyWalletViewController(viewModel: viewModel)
        
        return viewController
    }
    
    func getPaymentWalletViewController() -> UIViewController {
        return PaymentWalletViewController()
    }
    
    func toLoyaltyWalletViewController() {
        navController?.pushViewController(getLoyaltyWalletViewController(), animated: true)
    }
    
    func toAddingOptionsViewController() {
        let viewModel = AddingOptionsViewModel(router: self)
        let viewController = AddingOptionsViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toBrowseBrandsViewController() {
        let repository = BrowseBrandsRepository(apiManager: apiManager)
        let viewModel = BrowseBrandsViewModel(repository: repository, router: self)
        let viewController = BrowseBrandsViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toBarcodeViewController() {
        let viewModel = BarcodeViewModel()
        let viewController = BarcodeViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toAddOrJoinViewController(membershipPlan: MembershipPlanModel) {
        let viewModel = AddOrJoinViewModel(membershipPlan: membershipPlan, router: self)
        let viewController = AddOrJoinViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func showDeleteConfirmationAlert(yesCompletion: @escaping () -> Void, noCompletion: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: "delete_card_confirmation".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "no".localized, style: .cancel, handler: { _ in
            noCompletion()
        }))
        alert.addAction(UIAlertAction(title: "yes".localized, style: .destructive, handler: { _ in
            yesCompletion()
        }))
        navController?.present(alert, animated: true, completion: nil)
    }
    
    func displaySimplePopup(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        navController?.present(alert, animated: true, completion: nil)
    }
    
    func popViewController() {
        navController?.popViewController(animated: true)
    }
    
    func popToRootViewController() {
        if let tabBarVC = navController?.viewControllers.first(where: { $0 is MainTabBarViewController }) {
            navController?.popToViewController(tabBarVC, animated: true)
        } else {
            navController?.popToRootViewController(animated: true)
        }
    }
}
