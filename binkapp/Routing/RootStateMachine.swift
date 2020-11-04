//
//  RootStateMachine.swift
//  binkapp
//
//  Created by Max Woodhams on 04/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import DTTJailbreakDetection

class RootStateMachine: NSObject, UserServiceProtocol {
    private var window: UIWindow?
    private lazy var migrationController = UserMigrationController()
    
    func launch(withWindow window: UIWindow) {
        self.window = window
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout), name: .shouldLogout, object: nil)

        if DTTJailbreakDetection.isJailbroken() {
            moveTo(ViewControllerFactory.makeJailbrokenViewController())
        } else if Current.userManager.currentToken == nil {
            handleUnauthenticated()
        } else {
            handleLogin()
        }
        
        window.tintColor = .black
        window.makeKeyAndVisible()
    }
    
    private func handleUnauthenticated() {
        if migrationController.shouldMigrate {
            // Move to splash
            let loading = LoadingScreen()
            moveTo(loading)
            migrationController.renewTokenFromLegacyAppIfPossible { success in
                DispatchQueue.main.async { [weak self] in
                    if success {
                        self?.handleLogin()
                    } else {
                        self?.moveTo(ViewControllerFactory.makeOnboardingViewController())
                    }
                }
            }
        } else {
            moveTo(ViewControllerFactory.makeOnboardingViewController())
        }
    }

    func handleLogin() {
        let tabBarController = MainTabBarViewController(viewModel: MainTabBarViewModel())
        moveTo(tabBarController)
    }
    
    /// User driven logout that triggers API call and clears local storage
    @objc func handleLogout() {
        let loading = LoadingScreen()
        moveTo(loading)

        defer {
            clearLocalStorage { [weak self] in
                self?.completeLogout()
            }
        }

        if Current.apiClient.networkIsReachable {
            // Call the logout endpoint, but we don't care about the response.
            // On success or error, we will defer to clearing local storage and clearing the user's token.
            logout()
        }
    }
    
    private func clearLocalStorage(completion: @escaping () -> ()) {
        Current.database.performBackgroundTask { context in
            context.deleteAll(CD_MembershipCard.self)
            context.deleteAll(CD_PaymentCard.self)
            context.deleteAll(CD_BaseObject.self) // Cleanup any orphaned objects
            try? context.save()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    @objc func completeLogout() {
        Current.userManager.removeUser()
        Current.userDefaults.set(false, forDefaultsKey: .hasLaunchedWallet)
        NotificationCenter.default.post(name: .shouldTrashLocalWallets, object: nil)
        moveTo(ViewControllerFactory.makeOnboardingViewController())
    }
    
    func moveTo(_ viewController: UIViewController?) {
        guard let window = window else { fatalError("Window does not exist. This should never happen.")}
        window.rootViewController = viewController
        Current.navigate.setRootViewController(viewController)
    }
}
