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
    private var loadingCompleteViewController: UIViewController?
    
    func launch(withWindow window: UIWindow) {
        self.window = window
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout), name: .shouldLogout, object: nil)

        if Current.userManager.currentToken == nil {
            handleUnauthenticated()
        } else {
            handleLogin(for: .password)
        }
        
        window.tintColor = .black
        window.makeKeyAndVisible()
    }
    
    private func handleUnauthenticated() {
        moveTo(ViewControllerFactory.makeOnboardingViewController())
    }
    
    /// Presents a loading screen on the key window
    /// - Parameter viewController: The view controller that should return to view once loading is complete.
    func startLoading(from viewController: UIViewController? = nil) {
        loadingCompleteViewController = viewController
        let loading = LoadingScreen()
        moveTo(loading)
    }
    
    func stopLoading() {
        moveTo(loadingCompleteViewController)
        loadingCompleteViewController = nil
    }
    
    func handleMagicLink() {
        /// We know that if we don't successfully login, we should fallback to the onboarding screen with no user once loading completes.
        handleUnauthenticated()
        Current.userManager.removeUser()
    }

    func handleLogin(for loginType: LoginType) {
        let tabBarController = MainTabBarViewController(viewModel: MainTabBarViewModel())
        moveTo(tabBarController)
        
        switch loginType {
        case .magicLink:
            let successViewController = ViewControllerFactory.makeLoginSuccessViewController()
            let navigationRequest = ModalNavigationRequest(viewController: successViewController, dragToDismiss: false, hideCloseButton: true)
            Current.navigate.to(navigationRequest)
        default:
            break
        }
    }
    
    /// User driven logout that triggers API call and clears local storage
    @objc func handleLogout() {
        startLoading()
        defer {
            /// We want to remove credentials for scrapable cards before we trash all local membership cards
            Current.pointsScrapingManager.handleLogout()
            
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
    
    private func clearLocalStorage(completion: @escaping () -> Void) {
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
        Current.wallet.handleLogout()
        NotificationCenter.default.post(name: .shouldTrashLocalWallets, object: nil)
        moveTo(ViewControllerFactory.makeOnboardingViewController())
    }
    
    func moveTo(_ viewController: UIViewController?) {
        guard let window = window else { fatalError("Window does not exist. This should never happen.") }
        window.rootViewController = viewController
        Current.navigate.setRootViewController(viewController)
    }
}
