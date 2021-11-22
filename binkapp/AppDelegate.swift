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
import AlamofireNetworkActivityLogger
import CardScan
import Keys
import SafariServices
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UserServiceProtocol {
    var window: UIWindow?
    var stateMachine: RootStateMachine?
    
    let universalLinkUtility = UniversalLinkUtility()
    let widgetController = WidgetController()
    let watchController = WatchController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
        ScanViewController.configure(apiKey: BinkappKeys().bouncerPaymentCardScanningKeyDev)
        #endif
        
        if UIApplication.isRunningUITests {
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

        // Device storage
        StorageUtility.start()
        
        // Remote config
        Current.remoteConfig.configure()

        // Initialise Zendesk
        ZendeskService.start()
        
        // Start points scraping manager
        Current.pointsScrapingManager.start()
        
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
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if #available(iOS 14.0, *) {
            BinkLogger.info(event: AppLoggerEvent.appEnteredForeground)
        }
        Current.wallet.refreshMembershipPlansIfNecessary()
        InAppReviewUtility.recordAppLaunch()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if #available(iOS 14.0, *) {
            BinkLogger.info(event: AppLoggerEvent.appEnteredBackground)
        }
        Current.wallet.handleAppDidEnterBackground()
    }
    
    // MARK: - Universal Link Handling
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
            return false
        }
        
        universalLinkUtility.handleLink(for: url)
        
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.absoluteString.starts(with: "bink://magiclink?token=") {
            universalLinkUtility.handleLink(for: url)
        } else {
            widgetController.handleURLForWidgetType(type: .quickLaunch, url: url)
        }
        return true
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
        let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.errorTitle, message: L10n.communicationError)
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }

    @objc func presentSSLPinningFailurePopup() {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.sslPinningFailureTitle, message: L10n.sslPinningFailureText)
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


// MARK: - Watch Connectivity

extension AppDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch is active")
        print(session.isReachable)
    }
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Watch Inactive")
        print(session.isReachable)
    }
    func sessionDidDeactivate(_ session: WCSession) {
        print("Watch did Deactivate")
        print(session.isReachable)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let _ = message["watch_app_launch"] as? Bool {
                if Current.userManager.hasCurrentUser {
                    Current.watchController.sendWalletCardsToWatch(membershipCards: Current.wallet.membershipCards)
                } else {
                    Current.watchController.hasCurrentUser(false)
                }
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Watch reachability didChange")
        print(session.isReachable)
    }
}
