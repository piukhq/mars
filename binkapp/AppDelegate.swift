//
//  AppDelegate.swift
//  binkapp
//
//  Created by Karl Sigiscar on 04/07/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FBSDKCoreKit
import AlamofireNetworkActivityLogger
import CardScan
import Keys
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UserServiceProtocol {
    var window: UIWindow?
    var stateMachine: RootStateMachine?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
        ScanViewController.configure(apiKey: BinkappKeys().bouncerPaymentCardScanningKeyDev)
        #endif
        
        if CommandLine.arguments.contains("enable-testing") {
            configureAppForTesting()
        }
        
        // Firebase
        Analytics.setUserID(Current.userManager.currentUserId)
        FirebaseApp.configure()
       
        // Sentry Crash Reporting
        SentryService.start()
    
        #if RELEASE
        BinkAnalytics.beginSessionTracking()
        ScanViewController.configure(apiKey: BinkappKeys().bouncerPaymentCardScanningKeyProduction)
        #endif

        // Facebook
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        // Device storage
        StorageUtility.start()
        
        // Remote config
        Current.remoteConfig.configure()

        // Initialise Zendesk
        ZendeskService.start()
        
        // Get latest user profile data
        if Current.userManager.hasCurrentUser {
            getUserProfile { result in
                guard let response = try? result.get() else { return }
                Current.userManager.setProfile(withResponse: response, updateZendeskIdentity: true)
            }
        }

        // Root view
        self.window = UIWindow(frame: UIScreen.main.bounds)

        if let mainWindow = self.window {
            Current.rootStateMachine.launch(withWindow: mainWindow)
        }

        addObservers()
        InAppReviewUtility.recordAppLaunch()
        Current.userManager.clearKeychainIfNecessary()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if #available(iOS 14.0, *) {
            BinkLogger.info(.appEnteredForeground, value: nil, category: .appDelegate)
        }
        Current.wallet.refreshMembershipPlansIfNecessary()
        InAppReviewUtility.recordAppLaunch()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if #available(iOS 14.0, *) {
            BinkLogger.info(.appEnteredBackground, value: nil, category: .appDelegate)
        }
        Current.wallet.handleAppDidEnterBackground()
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // Facebook
        ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}

private extension AppDelegate {
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentSSLPinningFailurePopup), name: .didFailServerTrustEvaluation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayOutageError), name: .outageError, object: nil)
    }

    @objc func displayOutageError() {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: "error_title".localized, message: "communication_error".localized)
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }

    @objc func presentSSLPinningFailurePopup() {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: "ssl_pinning_failure_title".localized, message: "ssl_pinning_failure_text".localized)
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }

    @objc func appWillResignActive() {
        guard let topViewController = UIViewController.topMostViewController() else { return }

        // Dismiss scanners and alerts
        if let navigationController = topViewController as? PortraitNavigationController {
            if navigationController.visibleViewController?.isKind(of: CardScan.ScanViewController.self) == true || navigationController.visibleViewController?.isKind(of: BarcodeScannerViewController.self) == true {
                Current.navigate.close(animated: false) {
                    self.displayLaunchScreen()
                    return
                }
            }
        }

        if topViewController.isKind(of: UIAlertController.self) {
            Current.navigate.close(animated: false) {
                self.displayLaunchScreen()
                return
            }
        }

        displayLaunchScreen()
    }

    func displayLaunchScreen() {
        // If there is no current user, we have no need to present the splash screen
        guard Current.userManager.hasCurrentUser else { return }

        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "LaunchScreen")
        let navigationRequest = ModalNavigationRequest(viewController: viewController, fullScreen: true, embedInNavigationController: false, transition: .crossDissolve)
        Current.navigate.to(navigationRequest)
    }

    @objc func appDidBecomeActive() {
        Current.navigate.closeShieldView()
    }
    
    func configureAppForTesting() {
        UIView.setAnimationsEnabled(false)
    }
}
