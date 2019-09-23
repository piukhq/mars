//
//  MainScreenRouter.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class MainScreenRouter {
    var navController: PortraitNavigationController?
    
    let apiManager = ApiManager()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(presentNoConnectivityPopup), name: .noInternetConnection, object: nil)
    }

    func toMainScreen() {
        let repository = MainTabBarRepository()
        let viewModel = MainTabBarViewModel(repository: repository, router: self)
        let viewController = MainTabBarViewController(viewModel: viewModel)

        navController?.pushViewController(viewController, animated: true)
    }
    
    func getNavigationControllerWithLoginScreen() -> UIViewController{
        navController = PortraitNavigationController(rootViewController: getLoginScreen())
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
        displaySimplePopup(title: "Oops", message: "Settings screen not yet implemented.")
    }
    
    func toDebugMenu() {
        let debugMenuFactory = DebugMenuFactory()
        let debugMenuViewModel = DebugMenuViewModel(debugMenuFactory: debugMenuFactory)
        let debugMenuViewController = DebugMenuTableViewController(viewModel: debugMenuViewModel)
        debugMenuFactory.delegate = debugMenuViewController

        let debugNavigationController = PortraitNavigationController(rootViewController: debugMenuViewController)
        navController?.present(debugNavigationController, animated: true, completion: nil)
    }
    
    func getLoyaltyWalletViewController() -> UIViewController {
        let repository = LoyaltyWalletRepository(apiManager: apiManager)
        let viewModel = LoyaltyWalletViewModel(repository: repository, router: self)
        let viewController = LoyaltyWalletViewController(viewModel: viewModel)
        
        return viewController
    }
    
    func getPaymentWalletViewController() -> UIViewController {
        let repository = PaymentWalletRepository()
        let viewModel = PaymentWalletViewModel(repository: repository, router: self)
        let viewController = PaymentWalletViewController(viewModel: viewModel)
        
        return viewController
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
    
    func toBarcodeViewController(membershipPlan: MembershipPlanModel, membershipCard: MembershipCardModel) {
        let viewModel = BarcodeViewModel(membershipPlan: membershipPlan, membershipCard: membershipCard)
        let viewController = BarcodeViewController(viewModel: viewModel)
        navController?.present(PortraitNavigationController(rootViewController: viewController), animated: true, completion: nil)
    }
    
    func toAddOrJoinViewController(membershipPlan: MembershipPlanModel) {
        let viewModel = AddOrJoinViewModel(membershipPlan: membershipPlan, router: self)
        let viewController = AddOrJoinViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toLoyaltyFullDetailsScreen(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel) {
        let repository = LoyaltyCardFullDetailsRepository(apiManager: apiManager)
        let viewModel = LoyaltyCardFullDetailsViewModel(membershipCard: membershipCard, membershipPlan: membershipPlan, repository: repository, router: self)
        let viewController = LoyaltyCardFullDetailsViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }

    func toAuthAndAddViewController(membershipPlan: MembershipPlanModel) {
        let repository = AuthAndAddRepository(apiManager: apiManager)
        let viewModel = AuthAndAddViewModel(repository: repository, router: self, membershipPlan: membershipPlan)
        let viewController = AuthAndAddViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toPllViewController(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel) {
        let viewModel = PLLScreenViewModel(membershipCard: membershipCard, membershipPlan: membershipPlan, router: self)
        let viewController = PLLScreenViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toTransactionsViewController(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel) {
        let viewModel = TransactionsViewModel(membershipCard: membershipCard, membershipPlan: membershipPlan, router: self)
        let viewController = TransactionsViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toPaymentTermsAndConditionsViewController() {
        let viewModel = PaymentTermsAndConditionsViewModel(router: self)
        let viewController = PaymentTermsAndConditionsViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toSimpleInfoViewController(pendingType: PendingType) {
        let viewModel = SimpleInfoViewModel(router: self, pendingType: pendingType)
        let viewController = SimpleInfoViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func showDeleteConfirmationAlert(withMessage message: String, yesCompletion: @escaping () -> Void, noCompletion: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
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
        alert.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: nil))
        navController?.present(alert, animated: true, completion: nil)
    }
    
    @objc func presentNoConnectivityPopup() {
        let alert = UIAlertController(title: nil, message: "no_internet_connection_title".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: nil))
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
