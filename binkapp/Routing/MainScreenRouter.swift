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
        let viewModel = MainTabBarViewModel(router: self)
        let viewController = MainTabBarViewController(viewModel: viewModel)

        navController?.pushViewController(viewController, animated: true)
    }
    
    func getNavigationControllerWithLoginScreen() -> UIViewController{
        navController = PortraitNavigationController(rootViewController: getLoginScreen())
        navController?.navigationBar.isTranslucent = true
        
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
        let repository = PaymentWalletRepository(apiManager: apiManager)
        let viewModel = PaymentWalletViewModel(repository: repository, router: self)
        let viewController = PaymentWalletViewController(viewModel: viewModel)
        
        return viewController
    }
    
    func getDummyViewControllerForAction() -> UIViewController {
        return AddingOptionsTabBarViewController()
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

    func toAddPaymentViewController() {
        //        let repository = BrowseBrandsRepository(apiManager: apiManager)
        //        let viewModel = BrowseBrandsViewModel(repository: repository, router: self)

        //TODO: Replace with information from scanner
        let card = PaymentCardCreateModel(fullPan: nil, nameOnCard: nil, month: nil, year: nil)

        let viewModel = AddPaymentCardViewModel(apiManager: apiManager, router: self, paymentCard: card)
        let viewController = AddPaymentCardViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }

    func toBarcodeViewController(membershipCard: CD_MembershipCard, completion: @escaping () -> ()) {
        let viewModel = BarcodeViewModel(membershipCard: membershipCard)
        let viewController = BarcodeViewController(viewModel: viewModel)
        navController?.present(PortraitNavigationController(rootViewController: viewController), animated: true, completion: completion)
    }
    
    func toAddOrJoinViewController(membershipPlan: CD_MembershipPlan) {
        let viewModel = AddOrJoinViewModel(membershipPlan: membershipPlan, router: self)
        let viewController = AddOrJoinViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toLoyaltyFullDetailsScreen(membershipCard: CD_MembershipCard) {
        let repository = LoyaltyCardFullDetailsRepository(apiManager: apiManager)
        let viewModel = LoyaltyCardFullDetailsViewModel(membershipCard: membershipCard, repository: repository, router: self)
        let viewController = LoyaltyCardFullDetailsViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }

    func toPaymentCardDetailViewController(paymentCard: CD_PaymentCard) {
        // TODO: repository
        let viewModel = PaymentCardDetailViewModel(paymentCard: paymentCard, router: self)
        let viewController = PaymentCardDetailViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }

    func toAuthAndAddViewController(membershipPlan: CD_MembershipPlan) {
        let repository = AuthAndAddRepository(apiManager: apiManager)
        let viewModel = AuthAndAddViewModel(repository: repository, router: self, membershipPlan: membershipPlan)
        let viewController = AuthAndAddViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toPllViewController(membershipCard: CD_MembershipCard) {
        let viewModel = PLLScreenViewModel(membershipCard: membershipCard, router: self)
        let viewController = PLLScreenViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toTransactionsViewController(membershipCard: CD_MembershipCard) {
        let viewModel = TransactionsViewModel(membershipCard: membershipCard, router: self)
        let viewController = TransactionsViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toPaymentTermsAndConditionsViewController(delegate: PaymentTermsAndConditionsViewControllerDelegate?) {
        let screenText = "terms_and_conditions_title".localized + "\n" + "lorem_ipsum".localized
        
        let attributedText = NSMutableAttributedString(string: screenText)
        
        attributedText.addAttribute(
            NSAttributedString.Key.font,
            value: UIFont.headline,
            range: NSRange(location: 0, length: ("terms_and_conditions_title".localized).count)
        )
        
        attributedText.addAttribute(
            NSAttributedString.Key.font,
            value: UIFont.bodyTextLarge,
            range: NSRange(location: ("terms_and_conditions_title".localized).count, length: ("lorem_ipsum".localized).count)
        )
        
        let configurationModel = ReusableModalConfiguration(title: "", text: attributedText, primaryButtonTitle: "accept".localized, secondaryButtonTitle: "decline".localized, tabBarBackButton: nil)
        let viewModel = PaymentTermsAndConditionsViewModel(configurationModel: configurationModel, router: self)
        let viewController = PaymentTermsAndConditionsViewController(viewModel: viewModel, delegate: delegate)
        viewController.delegate = delegate
        navController?.present(PortraitNavigationController(rootViewController: viewController), animated: true, completion: nil)
    }
    
    func toPrivacyAndSecurityViewController() {
        let title = "privacy_and_security_title".localized
        let body = "privacy_and_security_body".localized
        let linkText = "privacy_and_security_link".localized
        let screenText = title + "\n" + body
        
        let attributedText = NSMutableAttributedString(string: screenText)
        
        attributedText.addAttribute(
            NSAttributedString.Key.font,
            value: UIFont.headline,
            range: NSRange(location: 0, length: title.count)
        )
        
        attributedText.addAttribute(
            NSAttributedString.Key.font,
            value: UIFont.bodyTextLarge,
            range: NSRange(location: title.count, length: body.count)
        )
        
        let urlString = "https://bink.com/terms-and-conditions/#privacy-policy"
        if let validUrl = URL(string: urlString), let range = screenText.range(of: linkText)  {
            attributedText.addAttribute(.link,
                                        value: validUrl,
                                        range: NSRange(range, in: body))
        }
            
        let configurationModel = ReusableModalConfiguration(title: title, text: attributedText, primaryButtonTitle: nil, secondaryButtonTitle: nil, tabBarBackButton: nil, showCloseButton: true)
        let viewModel = ReusableModalViewModel(configurationModel: configurationModel, router: self)
        let viewController = PaymentTermsAndConditionsViewController(viewModel: viewModel, delegate: nil)
        navController?.present(PortraitNavigationController(rootViewController: viewController), animated: true, completion: nil)
    }
    
    func toReusableModalTemplateViewController(configurationModel: ReusableModalConfiguration) {
        let viewModel = ReusableModalViewModel(configurationModel: configurationModel, router: self)
        let viewController = PaymentTermsAndConditionsViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
        navController?.present(PortraitNavigationController(rootViewController: viewController), animated: true, completion: nil)
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
    
    func dismissViewController(completion: (() -> Void)? = nil) {
        navController?.dismiss(animated: true, completion: completion)
    }
    
    func popToRootViewController() {
        if let tabBarVC = navController?.viewControllers.first(where: { $0 is MainTabBarViewController }) {
            navController?.popToViewController(tabBarVC, animated: true)
        } else {
            navController?.popToRootViewController(animated: true)
        }
    }
}
