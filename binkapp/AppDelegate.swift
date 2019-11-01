//
//  AppDelegate.swift
//  binkapp
//
//  Created by Karl Sigiscar on 04/07/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import Firebase
import AlamofireNetworkActivityLogger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
        #endif

        let router = MainScreenRouter()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if let mainWindow = self.window {
            mainWindow.rootViewController = router.getNavigationControllerWithLoginScreen()
            mainWindow.tintColor = .black
            mainWindow.makeKeyAndVisible()
        }

        // Crashlytics
        Fabric.with([Crashlytics.self])
        
        if #available(iOS 13, *) {
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithTransparentBackground()
            navAppearance.shadowImage = UIImage()
            navAppearance.backgroundColor = .init(white: 1.0, alpha: 0.6)
            navAppearance.backgroundEffect = UIBlurEffect(style: .light)
            navAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.navBar, NSAttributedString.Key.foregroundColor: UIColor.black]
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
            
            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithTransparentBackground()
            tabAppearance.shadowImage = UIImage()
            tabAppearance.backgroundColor = .init(white: 1.0, alpha: 0.6)
            tabAppearance.backgroundEffect = UIBlurEffect(style: .light)
            UITabBar.appearance().standardAppearance = tabAppearance
        }
        
        let attributes = [NSAttributedString.Key.font: UIFont.tabBar, NSAttributedString.Key.foregroundColor: UIColor.black]
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .disabled)
        
        // Firebase
        
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            if let filePath = Bundle.main.path(forResource: "\(bundleIdentifier).GoogleService-Info", ofType: "plist") {
                if let fileopts = FirebaseOptions(contentsOfFile: filePath) {
                    FirebaseApp.configure(options: fileopts)
                }
            }
        }

        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootViewController = application.topViewControllerWithRootViewController(rootViewController: window?.rootViewController),
            let barcodeModal = rootViewController as? BarcodeViewController,
            barcodeModal.isBarcodeFullsize {
            return .landscapeRight
        }
        
        // Only allow portrait (standard behaviour)
        return .portrait
    }
}

