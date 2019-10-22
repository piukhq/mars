//
//  OnboardingViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 21/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class OnboardingViewModel {
    private let router: MainScreenRouter
    private let repository: LoginRepository

    private let fallbackUserEmail = "Bink20iteration1@testbink.com"

    private var userEmail: String {
        guard let userEmail = Current.userDefaults.string(forKey: "userEmail") else {
            Current.userDefaults.set(fallbackUserEmail, forKey: "userEmail")
            return fallbackUserEmail
        }
        return userEmail
    }

    init(router: MainScreenRouter, repository: LoginRepository) {
        self.router = router
        self.repository = repository
    }

    var signUpWithEmailButtonText: String {
        return "Sign up with email"
    }

    var loginWithEmailButtonText: String {
        return "Log in with email"
    }

    func login() {
        repository.register(email: userEmail) { [weak self] in
            guard let self = self else { return }
            self.router.launchWallets()
        }
    }

    func notImplemented() {
        router.featureNotImplemented()
    }
}
