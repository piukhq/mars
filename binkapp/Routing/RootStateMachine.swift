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
    }
    
    func launch() {
        if Current.userManager.currentToken() == nil {
            handleUnauthenticated()
        } else {
            moveTo(router?.wallet())
        }
        
        window.tintColor = .black
        window.makeKeyAndVisible()
    }
    
    func handleUnauthenticated() {
        
        // At the moment, move them to the login screen
        moveTo(router?.getOnboardingViewController())
        
        if migrationController.shouldMigrate() {
            migrationController.renewTokenFromLegacyAppIfPossible { success in
                DispatchQueue.main.async { [weak self] in
                    if success {
                        self?.moveTo(self?.router?.wallet())
                        return
                    }
                }
            }
        }
    }
    
    @objc func handleLogout() {
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
