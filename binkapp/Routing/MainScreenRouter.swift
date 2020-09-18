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
    
    init(delegate: MainScreenRouterDelegate?) {
        self.delegate = delegate

//        NotificationCenter.default.addObserver(self, selector: #selector(presentNoConnectivityPopup), name: .noInternetConnection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)

        // SSL Pinning failure
        NotificationCenter.default.addObserver(self, selector: #selector(presentSSLPinningFailurePopup), name: .didFailServerTrustEvaluation, object: nil)
        
        //Outage error - Server 500-599 status code
        NotificationCenter.default.addObserver(self, selector: #selector(displayOutageError), name: .outageError, object: nil)
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
        let viewModel = SettingsViewModel(rowsWithActionRequired: rowsWithActionRequired)
        let settingsVC = SettingsViewController(viewModel: viewModel)
        let settingsNav = PortraitNavigationController(rootViewController: settingsVC)
        settingsNav.modalPresentationStyle = .fullScreen
        navController?.present(settingsNav, animated: true, completion: nil)
    }
    
    func toBrowseBrandsViewController() {
        let repository = BrowseBrandsRepository(apiClient: apiClient)
        let viewModel = BrowseBrandsViewModel(repository: repository, router: self)
        let viewController = BrowseBrandsViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }

    func toLoyaltyScanner(forPlan plan: CD_MembershipPlan? = nil, delegate: BarcodeScannerViewControllerDelegate?) {
        let viewModel = BarcodeScannerViewModel(plan: plan)
        let viewController = BarcodeScannerViewController(viewModel: viewModel, delegate: delegate)
        
        let enterManuallyAlert = UIAlertController.cardScannerEnterManuallyAlertController { [weak self] in
            self?.toBrowseBrandsViewController()
        }
        
        if PermissionsUtility.videoCaptureIsAuthorized {
            if plan == nil {
                navController?.pushViewController(viewController, animated: true)
            } else {
                navController?.present(viewController, animated: true, completion: nil)
            }
        } else if PermissionsUtility.videoCaptureIsDenied {
            if let alert = enterManuallyAlert {
                navController?.present(alert, animated: true, completion: nil)
            }
        } else {
            PermissionsUtility.requestVideoCaptureAuthorization { [weak self] granted in
                if granted {
                    if plan == nil {
                        self?.navController?.pushViewController(viewController, animated: true)
                    } else {
                        self?.navController?.present(viewController, animated: true, completion: nil)
                    }
                } else {
                    if let alert = enterManuallyAlert {
                        self?.navController?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func toPaymentCardScanner(strings: ScanStringsDataSource, delegate: ScanDelegate?) {
        guard let paymentCardScanner = ScanViewController.createViewController(withDelegate: delegate) else { return }
        paymentCardScanner.allowSkip = true
        paymentCardScanner.cornerColor = .white
        paymentCardScanner.torchButtonImage = UIImage(named: "payment_scanner_torch")
        paymentCardScanner.stringDataSource = strings
        
        let enterManuallyAlert = UIAlertController.cardScannerEnterManuallyAlertController { [weak self] in
            self?.toAddPaymentViewController()
        }
        
        if PermissionsUtility.videoCaptureIsAuthorized {
            navController?.pushViewController(paymentCardScanner, animated: true)
        } else if PermissionsUtility.videoCaptureIsDenied {
            if let alert = enterManuallyAlert {
                navController?.present(alert, animated: true, completion: nil)
            }
        } else {
            PermissionsUtility.requestVideoCaptureAuthorization { [weak self] granted in
                if granted {
                    self?.navController?.pushViewController(paymentCardScanner, animated: true)
                } else {
                    if let alert = enterManuallyAlert {
                        self?.navController?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    func toAddPaymentViewController(model: PaymentCardCreateModel? = nil) {
        let viewModel = AddPaymentCardViewModel(router: self, paymentCard: model)
        let viewController = AddPaymentCardViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toAddOrJoinViewController(membershipPlan: CD_MembershipPlan, membershipCard: CD_MembershipCard? = nil) {
        let viewModel = AddOrJoinViewModel(membershipPlan: membershipPlan, membershipCard: membershipCard, router: self)
        let viewController = AddOrJoinViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }

    func toAuthAndAddViewController(membershipPlan: CD_MembershipPlan, formPurpose: FormPurpose, existingMembershipCard: CD_MembershipCard? = nil, prefilledFormValues: [FormDataSource.PrefilledValue]? = nil) {
        let viewModel = AuthAndAddViewModel(router: self, membershipPlan: membershipPlan, formPurpose: formPurpose, existingMembershipCard: existingMembershipCard, prefilledFormValues: prefilledFormValues)
        let viewController = AuthAndAddViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toPatchGhostCard(membershipPlan: CD_MembershipPlan, existingMembershipCard: CD_MembershipCard? = nil) {
        let viewModel = AuthAndAddViewModel(router: self, membershipPlan: membershipPlan, formPurpose: .patchGhostCard, existingMembershipCard: existingMembershipCard)
        let viewController = AuthAndAddViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toSignUp(membershipPlan: CD_MembershipPlan, existingMembershipCard: CD_MembershipCard? = nil) {
        let viewModel = AuthAndAddViewModel(router: self, membershipPlan: membershipPlan, formPurpose: .signUp, existingMembershipCard: existingMembershipCard)
        let viewController = AuthAndAddViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toPllViewController(membershipCard: CD_MembershipCard, journey: PllScreenJourney ) {
        let viewModel = PLLScreenViewModel(membershipCard: membershipCard, router: self, journey: journey)
        let viewController = PLLScreenViewController(viewModel: viewModel, journey: journey)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toTransactionsViewController(membershipCard: CD_MembershipCard) {
        let viewModel = TransactionsViewModel(membershipCard: membershipCard, router: self)
        let viewController = TransactionsViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func toPaymentTermsAndConditionsViewController(configurationModel: ReusableModalConfiguration, delegate: ReusableTemplateViewControllerDelegate?) {
        let viewModel = PaymentTermsAndConditionsViewModel(configurationModel: configurationModel)
        let viewController = ReusableTemplateViewController(viewModel: viewModel, delegate: delegate)
        let navigationController = PortraitNavigationController(rootViewController: viewController)
        
        // This is to stop dismissal of the card style presentation
        if #available(iOS 13, *) {
            navigationController.isModalInPresentation = true
        }
        
        viewController.delegate = delegate
        navController?.present(navigationController, animated: true, completion: nil)
    }
    
    func toForgotPasswordViewController(navigationController: UINavigationController?) {
        let repository = ForgotPasswordRepository(apiClient: apiClient)
        let viewModel = ForgotPasswordViewModel(repository: repository)
        let viewController = ForgotPasswordViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func toReusableModalTemplateViewController(configurationModel: ReusableModalConfiguration, floatingButtons: Bool = true) {
        let viewModel = ReusableModalViewModel(configurationModel: configurationModel)
        let viewController = ReusableTemplateViewController(viewModel: viewModel, floatingButtons: floatingButtons)
        navController?.present(PortraitNavigationController(rootViewController: viewController), animated: true, completion: nil)
    }
    
    func pushReusableModalTemplateVC(configurationModel: ReusableModalConfiguration, navigationController: UINavigationController?, floatingButtons: Bool = true) {
        let viewModel = ReusableModalViewModel(configurationModel: configurationModel)
        let viewController = ReusableTemplateViewController(viewModel: viewModel, floatingButtons: floatingButtons)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func toSimpleInfoViewController(pendingType: PendingType) {
        let viewModel = SimpleInfoViewModel(router: self, pendingType: pendingType)
        let viewController = SimpleInfoViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }

    func toPaymentCardNeededScreen(strings: ScanStringsDataSource, scanDelegate: ScanDelegate?) {
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        let configuration = ReusableModalConfiguration(title: "", text: ReusableModalConfiguration.makeAttributedString(title: "plr_payment_card_needed_title".localized, description: "plr_payment_card_needed_body".localized), primaryButtonTitle: "pll_screen_add_title".localized, mainButtonCompletion: { [weak self] in
            self?.toPaymentCardScanner(strings: strings, delegate: scanDelegate)
        }, tabBarBackButton: backButton)
        pushReusableModalTemplateVC(configurationModel: configuration, navigationController: navController, floatingButtons: false)
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
