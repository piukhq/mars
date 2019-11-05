//
//  OnboardingViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 21/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class OnboardingViewModel {
    let router: MainScreenRouter
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
        return "signup_with_email_button".localized
    }

    var loginWithEmailButtonText: String {
        return "login_with_email_button".localized
    }

    func notImplemented() {
        router.featureNotImplemented()
    }
}
