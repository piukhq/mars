//
//  OnboardingViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 21/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class OnboardingViewModel {
    var signUpWithEmailButtonText: String {
        return L10n.signupWithEmailButton
    }

    var loginWithEmailButtonText: String {
        return L10n.loginWithEmailButton
    }
    
    func pushToSocialTermsAndConditions(requestType: SocialLoginRequestType) {
        let viewController = ViewControllerFactory.makeSocialTermsAndConditionsViewController(requestType: requestType)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func pushToRegister() {
        BinkAnalytics.track(OnboardingAnalyticsEvent.start(journey: .register))
        let viewController = ViewControllerFactory.makeRegisterViewController()
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func pushToLogin() {
        BinkAnalytics.track(OnboardingAnalyticsEvent.start(journey: .login))
        let viewController = ViewControllerFactory.makeLoginViewController()
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func openDebugMenu() {
        let viewController = ViewControllerFactory.makeDebugViewController()
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
}
