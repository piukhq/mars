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
    
    func toForgotPasswordViewController(navigationController: UINavigationController?) {
        let repository = ForgotPasswordRepository(apiClient: apiClient)
        let viewModel = ForgotPasswordViewModel(repository: repository)
        let viewController = ForgotPasswordViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
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
    
    func didLogin() {
        delegate?.router(self, didLogin: true)
    }
    
    // MARK: - App in background
    
    @objc func appWillResignActive() {
        guard let topViewController = UIViewController.topMostViewController() else { return }
        
        // This should be a temporary workaround while we wait for a change in Bouncer's library.
        if let navigationController = topViewController as? PortraitNavigationController, let presentingViewController = topViewController.presentingViewController {
            if navigationController.visibleViewController?.isKind(of: CardScan.ScanViewController.self) == true {
                navigationController.visibleViewController?.dismiss(animated: false, completion: {
                    self.displayLaunchScreen(visibleViewController: presentingViewController)
                    return
                })
            }
        }
        
        if topViewController.isKind(of: UIAlertController.self), let presentingViewController = topViewController.presentingViewController {
            topViewController.dismiss(animated: false) {
                self.displayLaunchScreen(visibleViewController: presentingViewController)
                return
            }
        }
        
        displayLaunchScreen(visibleViewController: topViewController)
    }
    
    private func displayLaunchScreen(visibleViewController: UIViewController) {
        // If there is no current user, we have no need to present the splash screen
        guard Current.userManager.hasCurrentUser else {
            return
        }
        
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LaunchScreen")
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        if let modalNavigationController = visibleViewController.navigationController, visibleViewController.isModal {
            modalNavigationController.present(vc, animated: false, completion: nil)
        } else {
            visibleViewController.present(vc, animated: false, completion: nil)
        }
    }
    
    @objc func appDidBecomeActive() {
        guard let visibleVC = UIViewController.topMostViewController() else { return }
        if let modalNavigationController = visibleVC.navigationController, visibleVC.isModal == true {
            modalNavigationController.dismiss(animated: true, completion: nil)
        } else if visibleVC.isKind(of: SFSafariViewController.self) == false {
            visibleVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func appWillEnterForeground() {
        //Fixme: Strange behaviour happening when user has to give canera permissions manually, once the user is on settings page if ge makes some changes(turning camera permissions switch on) when resumes the app this is called and the AddingOptionScreen is dismissed. If the user doesn't change anything on the settings screeen the AddingOptionsScreen will not be dismissed. 
    }
}
