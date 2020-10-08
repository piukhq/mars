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

        // Firebase
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
            stateMachine = RootStateMachine(window: mainWindow)
        }
        
        let backInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        let backButtonImage = UIImage(named: "navbarIconsBack")?.withAlignmentRectInsets(backInsets)
        
        if #available(iOS 13, *) {
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithTransparentBackground()
            navAppearance.shadowImage = UIImage()
            navAppearance.backgroundColor = .init(white: 1.0, alpha: 0.6)
            navAppearance.backgroundEffect = UIBlurEffect(style: .light)
            navAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.navBar, NSAttributedString.Key.foregroundColor: UIColor.black]
            // HACK: The transition mask image is.. broken
            navAppearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithTransparentBackground()
            tabAppearance.shadowImage = UIImage()
            tabAppearance.backgroundColor = .init(white: 1.0, alpha: 0.6)
            tabAppearance.backgroundEffect = UIBlurEffect(style: .light)
            UITabBar.appearance().standardAppearance = tabAppearance
        } else {
            UINavigationBar.appearance().backIndicatorImage = backButtonImage
            UINavigationBar.appearance().backIndicatorTransitionMaskImage = backButtonImage
        }
        
        let attributes = [NSAttributedString.Key.font: UIFont.tabBar, NSAttributedString.Key.foregroundColor: UIColor.black]
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .disabled)
    
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Current.wallet.refreshMembershipPlansIfNecessary()
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // Facebook
        ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}

