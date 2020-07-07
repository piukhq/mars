//
//  MainScreenRouter.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import SafariServices
import UIKit
import MessageUI
import CardScan

protocol MainScreenRouterDelegate: NSObjectProtocol {
    func router(_ router: MainScreenRouter, didLogin: Bool)
}

class MainScreenRouter {
    var navController: PortraitNavigationController?
    weak var delegate: MainScreenRouterDelegate?
    let apiClient = Current.apiClient
    
    init(delegate: MainScreenRouterDelegate) {
        self.delegate = delegate

        NotificationCenter.default.addObserver(self, selector: #selector(presentNoConnectivityPopup), name: .noInternetConnection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)

        // SSL Pinning failure
        NotificationCenter.default.addObserver(self, selector: #selector(presentSSLPinningFailurePopup), name: .didFailServerTrustEvaluation, object: nil)
        
        //Outage error - Server 500-599 status code
        NotificationCenter.default.addObserver(self, selector: #selector(displayOutageError), name: .outageError, object: nil)
    }
    
    func wallet() -> UIViewController {
        let viewModel = MainTabBarViewModel(router: self)
        let viewController = MainTabBarViewController(viewModel: viewModel)
        let nav = PortraitNavigationController(rootViewController: viewController)
        navController = nav
        return nav
    }

    func jailbroken() -> UIViewController {
        return JailbrokenViewController()
    }

    func getOnboardingViewController() -> UIViewController {
        let viewModel = OnboardingViewModel(router: self)
        let nav = PortraitNavigationController(rootViewController: OnboardingViewController(viewModel: viewModel))
        navController = nav
        return nav
    }

    func featureNotImplemented() {
        displaySimplePopup(title: "Oops", message: "This feature has not yet been implemented.")
    }
    
    func toSettings(rowsWithActionRequired: [SettingsRow.RowType]?) {
        let viewModel = SettingsViewModel(router: self, rowsWithActionRequired: rowsWithActionRequired)
        let settingsVC = SettingsViewController(viewModel: viewModel)
        let settingsNav = PortraitNavigationController(rootViewController: settingsVC)
        settingsNav.modalPresentationStyle = .fullScreen
        navController?.present(settingsNav, animated: true, completion: nil)
    }
    
    func getLoyaltyWalletViewController() -> UIViewController {
        let repository = LoyaltyWalletRepository(apiClient: apiClient)
        let viewModel = LoyaltyWalletViewModel(repository: repository, router: self)
        let viewController = LoyaltyWalletViewController(viewModel: viewModel)
        viewModel.paymentScanDelegate = viewController
        
        return viewController
    }
    
    func getPaymentWalletViewController() -> UIViewController {
        let viewModel = PaymentWalletViewModel(repository: PaymentWalletRepository(apiClient: apiClient), router: self)
        let viewController = PaymentWalletViewController(viewModel: viewModel)
        viewModel.paymentScanDelegate = viewController
        
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
        let repository = BrowseBrandsRepository(apiClient: apiClient)
        let viewModel = BrowseBrandsViewModel(repository: repository, router: self)
        let viewController = BrowseBrandsViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }

    func toLoyaltyScanner(delegate: BarcodeScannerViewControllerDelegate?) {
        let viewModel = BarcodeScannerViewModel()
        let viewController = BarcodeScannerViewController(viewModel: viewModel, delegate: delegate)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toPaymentCardScanner(strings: ScanStringsDataSource, delegate: ScanDelegate?) {
        if let viewController = ScanViewController.createViewController(withDelegate: delegate) {
            viewController.allowSkip = true
            viewController.cornerColor = .white
            viewController.torchButtonImage = UIImage(named: "payment_scanner_torch")
            viewController.stringDataSource = strings
            navController?.pushViewController(viewController, animated: true)
        }
    }

    func toAddPaymentViewController(model: PaymentCardCreateModel? = nil) {
        let repository = PaymentWalletRepository(apiClient: apiClient)
        let viewModel = AddPaymentCardViewModel(router: self, repository: repository, paymentCard: model)
        let viewController = AddPaymentCardViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }

    func toBarcodeViewController(membershipCard: CD_MembershipCard, completion: @escaping () -> ()) {
        let viewModel = BarcodeViewModel(membershipCard: membershipCard)
        let navigationController = PortraitNavigationController(rootViewController: BarcodeViewController(viewModel: viewModel))
        navigationController.modalPresentationStyle = .fullScreen
        navController?.present(navigationController,  animated: true, completion: completion)
    }
    
    func toAddOrJoinViewController(membershipPlan: CD_MembershipPlan, membershipCard: CD_MembershipCard? = nil) {
        let viewModel = AddOrJoinViewModel(membershipPlan: membershipPlan, membershipCard: membershipCard, router: self)
        let viewController = AddOrJoinViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toLoyaltyFullDetailsScreen(membershipCard: CD_MembershipCard) {
        let repository = LoyaltyCardFullDetailsRepository(apiClient: apiClient)
        let factory = PaymentCardDetailInformationRowFactory()
        let viewModel = LoyaltyCardFullDetailsViewModel(membershipCard: membershipCard, repository: repository, router: self, informationRowFactory: factory)
        let viewController = LoyaltyCardFullDetailsViewController(viewModel: viewModel)
        factory.delegate = viewController
        navController?.pushViewController(viewController, animated: true)
    }

    func toPaymentCardDetailViewController(paymentCard: CD_PaymentCard) {
        let repository = PaymentCardDetailRepository(apiClient: apiClient)
        let factory = PaymentCardDetailInformationRowFactory()
        let viewModel = PaymentCardDetailViewModel(paymentCard: paymentCard, router: self, repository: repository, informationRowFactory: factory)
        let viewController = PaymentCardDetailViewController(viewModel: viewModel)
        factory.delegate = viewController
        navController?.pushViewController(viewController, animated: true)
    }

    func toAuthAndAddViewController(membershipPlan: CD_MembershipPlan, formPurpose: FormPurpose, existingMembershipCard: CD_MembershipCard? = nil) {
        let repository = AuthAndAddRepository(apiClient: apiClient)
        let viewModel = AuthAndAddViewModel(repository: repository, router: self, membershipPlan: membershipPlan, formPurpose: formPurpose, existingMembershipCard: existingMembershipCard)
        let viewController = AuthAndAddViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toPatchGhostCard(membershipPlan: CD_MembershipPlan, existingMembershipCard: CD_MembershipCard? = nil) {
        let repository = AuthAndAddRepository(apiClient: apiClient)
        let viewModel = AuthAndAddViewModel(repository: repository, router: self, membershipPlan: membershipPlan, formPurpose: .patchGhostCard, existingMembershipCard: existingMembershipCard)
        let viewController = AuthAndAddViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toSignUp(membershipPlan: CD_MembershipPlan, existingMembershipCard: CD_MembershipCard? = nil) {
        let repository = AuthAndAddRepository(apiClient: apiClient)
        let viewModel = AuthAndAddViewModel(repository: repository, router: self, membershipPlan: membershipPlan, formPurpose: .signUp, existingMembershipCard: existingMembershipCard)
        let viewController = AuthAndAddViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toPllViewController(membershipCard: CD_MembershipCard, journey: PllScreenJourney ) {
        let repository = PLLScreenRepository(apiClient: apiClient)
        let viewModel = PLLScreenViewModel(membershipCard: membershipCard, repository: repository, router: self, journey: journey)
        let viewController = PLLScreenViewController(viewModel: viewModel, journey: journey)
        navController?.pushViewController(viewController, animated: true)
    }

    func toVoucherDetailViewController(voucher: CD_Voucher, plan: CD_MembershipPlan) {
        let viewModel = PLRRewardDetailViewModel(voucher: voucher, plan: plan, router: self)
        let viewController = PLRRewardDetailViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }

    func toRewardsHistoryViewController(membershipCard: CD_MembershipCard) {
        let viewModel = PLRRewardsHistoryViewModel(membershipCard: membershipCard, router: self)
        let viewController = PLRRewardsHistoryViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toTransactionsViewController(membershipCard: CD_MembershipCard) {
        let viewModel = TransactionsViewModel(membershipCard: membershipCard, router: self)
        let viewController = TransactionsViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toPaymentTermsAndConditionsViewController(configurationModel: ReusableModalConfiguration, delegate: ReusableTemplateViewControllerDelegate?) {
        let viewModel = PaymentTermsAndConditionsViewModel(configurationModel: configurationModel, router: self)
        let viewController = ReusableTemplateViewController(viewModel: viewModel, delegate: delegate)
        let navigationController = PortraitNavigationController(rootViewController: viewController)
        
        // This is to stop dismissal of the card style presentation
        if #available(iOS 13, *) {
            navigationController.isModalInPresentation = true
        }
        
        viewController.delegate = delegate
        navController?.present(navigationController, animated: true, completion: nil)
    }
    
    func toPrivacyAndSecurityViewController() {
        let title = "security_and_privacy_title".localized
        let body = "security_and_privacy_description".localized
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
            
        let configurationModel = ReusableModalConfiguration(title: title, text: attributedText, primaryButtonTitle: nil, secondaryButtonTitle: nil, tabBarBackButton: nil, showCloseButton: true)
        toReusableModalTemplateViewController(configurationModel: configurationModel)
    }
    
    func toForgotPasswordViewController(navigationController: UINavigationController?) {
        let repository = ForgotPasswordRepository(apiClient: apiClient)
        let viewModel = ForgotPasswordViewModel(repository: repository)
        let viewController = ForgotPasswordViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func toReusableModalTemplateViewController(configurationModel: ReusableModalConfiguration, floatingButtons: Bool = true) {
        let viewModel = ReusableModalViewModel(configurationModel: configurationModel, router: self)
        let viewController = ReusableTemplateViewController(viewModel: viewModel, floatingButtons: floatingButtons)
        navController?.present(PortraitNavigationController(rootViewController: viewController), animated: true, completion: nil)
    }
    
    func pushReusableModalTemplateVC(configurationModel: ReusableModalConfiguration, navigationController: UINavigationController?, floatingButtons: Bool = true) {
        let viewModel = ReusableModalViewModel(configurationModel: configurationModel, router: self)
        let viewController = ReusableTemplateViewController(viewModel: viewModel, floatingButtons: floatingButtons)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func toSimpleInfoViewController(pendingType: PendingType) {
        let viewModel = SimpleInfoViewModel(router: self, pendingType: pendingType)
        let viewController = SimpleInfoViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }

    func toPaymentCardNeededScreen() {
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        let configuration = ReusableModalConfiguration(title: "", text: ReusableModalConfiguration.makeAttributedString(title: "plr_payment_card_needed_title".localized, description: "plr_payment_card_needed_body".localized), primaryButtonTitle: "pll_screen_add_title".localized, mainButtonCompletion: { [weak self] in
            self?.toAddPaymentViewController()
        }, tabBarBackButton: backButton)
        pushReusableModalTemplateVC(configurationModel: configuration, navigationController: navController, floatingButtons: false)
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
    
    func showNoBarcodeAlert(completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "No Barcode", message: "No barcode or card number to display. Please check the status of this card.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { _ in
            completion()
        }))
        navController?.present(alert, animated: true, completion: nil)
    }
    
    func displaySimplePopup(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: nil))
        navController?.present(alert, animated: true, completion: nil)
    }
    
    @objc func displayOutageError() {
        let alert = UIAlertController(title: "error_title".localized, message: "communication_error".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
        navController?.present(alert, animated: true, completion: nil)
    }
    
    @objc func presentNoConnectivityPopup() {
        displayNoConnectivityPopup(completion: nil)
    }
    
    func displayNoConnectivityPopup(completion: (() -> Void)? = nil) {
        guard let visibleVC = navController?.getVisibleViewController() else { return }
        let alert = UIAlertController(title: nil, message: "no_internet_connection_message".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: { _ in
            if let completion = completion {
                completion()
            }
        }))
        if let modalNavigationController = visibleVC.navigationController, visibleVC.isModal {
            modalNavigationController.present(alert, animated: false, completion: nil)
        } else {
            navController?.present(alert, animated: false, completion: nil)
        }
    }

    @objc func presentSSLPinningFailurePopup() {
        let alert = UIAlertController(title: "ssl_pinning_failure_title".localized, message: "ssl_pinning_failure_text".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: nil))
        navController?.present(alert, animated: true, completion: nil)
    }
    
    @objc func popViewController() {
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
    
    func didLogin() {
        delegate?.router(self, didLogin: true)
    }
    
    func openWebView(withUrlString urlString: String) {
        let webViewController = PortraitNavigationController(rootViewController: WebViewController(urlString: urlString))
        webViewController.modalPresentationStyle = .fullScreen
        
        guard let presentedViewController = navController?.presentedViewController else {
            navController?.present(webViewController, animated: true)
            return
        }
        presentedViewController.present(webViewController, animated: true)
    }
    
    class func openExternalURL(with urlString: String) {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    //MARK: - App in background
    
    @objc func appWillResignActive() {
        guard let visibleVC = navController?.getVisibleViewController() else { return }
        
        // This should be a temporary workaround while we wait for a change in Bouncer's library.
        // We are removing the scanner from the navigation stack when we move the app to the background
        // This results in the user returning to the add options view.
        if let navigationController = visibleVC as? UINavigationController {
            for vc in navigationController.viewControllers {
                if vc.isKind(of: CardScan.ScanViewController.self) {
                    navigationController.removeViewController(vc)
                }
            }
        }
        if visibleVC.isKind(of: UIAlertController.self) == true || visibleVC.presentedViewController?.isKind(of: UIAlertController.self) == true || visibleVC.presentedViewController?.isKind(of: MFMailComposeViewController.self) == true {
            //Dismiss alert controller and mail composer before presenting the Launch screen.
            visibleVC.dismiss(animated: false) {
                self.displayLaunchScreen(visibleViewController: visibleVC)
            }
            return
        }
        
        if visibleVC.isModal {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.displayLaunchScreen(visibleViewController: visibleVC)
            }
        } else {
            displayLaunchScreen(visibleViewController: visibleVC)
        }
    }
    
    private func displayLaunchScreen(visibleViewController: UIViewController) {
        // If there is no current user, we have no need to present the splash screen
        guard Current.userManager.hasCurrentUser else {
            return
        }

        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LaunchScreen")
        vc.modalPresentationStyle = .fullScreen
        if let modalNavigationController = visibleViewController.navigationController, visibleViewController.isModal {
            modalNavigationController.present(vc, animated: false, completion: nil)
        } else {
            navController?.present(vc, animated: false, completion: nil)
        }
    }
    
    @objc func appDidBecomeActive() {
        let visibleVC = navController?.getVisibleViewController()
        if let modalNavigationController = visibleVC?.navigationController, visibleVC?.isModal == true {
           modalNavigationController.dismiss(animated: false, completion: nil)
        } else if visibleVC?.isKind(of: SFSafariViewController.self) == false {
            visibleVC?.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc func appWillEnterForeground() {
        //Fixme: Strange behaviour happening when user has to give canera permissions manually, once the user is on settings page if ge makes some changes(turning camera permissions switch on) when resumes the app this is called and the AddingOptionScreen is dismissed. If the user doesn't change anything on the settings screeen the AddingOptionsScreen will not be dismissed. 
    }
}
