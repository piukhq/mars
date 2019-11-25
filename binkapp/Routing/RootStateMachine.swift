//
//  RootStateMachine.swift
//  binkapp
//
//  Created by Max Woodhams on 04/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class RootStateMachine: NSObject {
    
    private let window: UIWindow
    private var router: MainScreenRouter?
    private lazy var migrationController = UserMigrationController()
    
    init(window: UIWindow) {
        self.window = window
        super.init()
        self.router = MainScreenRouter(delegate: self)
        launch()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout), name: .shouldLogout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(completeLogout), name: .didLogout, object: nil)
    }
    
    private func launch() {
        if Current.userManager.currentToken == nil {
            handleUnauthenticated()
        } else {
            moveTo(router?.wallet())
        }
        
        window.tintColor = .black
        window.makeKeyAndVisible()
    }
    
    private func handleUnauthenticated() {
        if migrationController.shouldMigrate() {
            // Move to splash
            let loading = LoadingScreen()
            moveTo(loading)
            migrationController.renewTokenFromLegacyAppIfPossible { success in
                DispatchQueue.main.async { [weak self] in
                    if success {
                        self?.moveTo(self?.router?.wallet())
                    } else {
                        self?.moveTo(self?.router?.getOnboardingViewController())
                    }
                }
            }
        } else {
            moveTo(router?.getOnboardingViewController())
        }
    }
    
    /// User driven logout that triggers API call and clears local storage
    @objc func handleLogout() {
        
        // Move to splash
        let loading = LoadingScreen()
        moveTo(loading)
                
        clearLocalStorage {
            let api = ApiManager()
            
            api.doRequest(url: .logout, httpMethod: .post, onSuccess: { [weak self] (response: LogoutResponse) in
                self?.completeLogout()
            }) { [weak self] (error) in
                self?.completeLogout()
            }
        }
    }
    
    private func clearLocalStorage(completion: @escaping () -> ()) {
        Current.database.performBackgroundTask { context in
            context.deleteAll(CD_MembershipCard.self)
            context.deleteAll(CD_PaymentCard.self)
            try? context.save()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    @objc func completeLogout() {
        Current.userManager.removeUser()
        moveTo(router?.getOnboardingViewController())
    }
    
    func moveTo(_ viewController: UIViewController?) {
        window.rootViewController = viewController
    }
}

extension RootStateMachine: MainScreenRouterDelegate {
    func router(_ router: MainScreenRouter, didLogin: Bool) {
        if didLogin {
            moveTo(router.wallet())
        }
    }
}
