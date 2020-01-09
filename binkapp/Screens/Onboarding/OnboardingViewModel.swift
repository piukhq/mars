//
//  OnboardingViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 21/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class OnboardingViewModel {
    let router: MainScreenRouter
    var navigationController: UINavigationController?

    private let fallbackUserEmail = "Bink20iteration1@testbink.com"

    private var userEmail: String {
        guard let userEmail = Current.userDefaults.string(forKey: .userEmail) else {
            Current.userDefaults.set(fallbackUserEmail, forKey: .userEmail)
            return fallbackUserEmail
        }
        return userEmail
    }

    init(router: MainScreenRouter) {
        self.router = router
    }

    var signUpWithEmailButtonText: String {
        return "signup_with_email_button".localized
    }

    var loginWithEmailButtonText: String {
        return "login_with_email_button".localized
    }
    
    var facebookLoginErrorTitle: String {
        return "error_title".localized
    }
    
    var facebookLoginCancelledText: String {
        return "facebook_cancelled".localized
    }
    
    var facebookLoginErrorText: String {
        return "facebook_error".localized
    }
    
    var facebookLoginOK: String {
        return "ok".localized
    }

    func notImplemented() {
        router.featureNotImplemented()
    }
    
    func pushToSocialTermsAndConditions(request: FacebookRequest) {
        let termsAndConditions = SocialTermsAndConditionsViewController(router: router, request: request)
        navigationController?.pushViewController(termsAndConditions, animated: true)
    }
    
    func pushToAddEmail(request: FacebookRequest) {
        let addEmail = AddEmailViewController(router: router, request: request) { [weak self] request in
            self?.pushToSocialTermsAndConditions(request: request)
        }
        
        navigationController?.pushViewController(addEmail, animated: true)
    }
    
    func pushToRegister() {
        navigationController?.pushViewController(RegisterViewController(router: router), animated: true)
    }
    
    func pushToLogin() {
        navigationController?.pushViewController(LoginViewController(router: router), animated: true)
    }
}
