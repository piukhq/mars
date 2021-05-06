//
//  LoginController.swift
//  binkapp
//
//  Created by Nick Farrant on 06/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

class LoginController: UserServiceProtocol {
    func login(with request: LoginRegisterRequest, completion: @escaping (Bool) -> Void) {
        login(request: request) { [weak self] result in
            self?.handleResult(result, completion: completion)
        }
    }
    
    func exchangeMagicLinkToken(token: String, completion: @escaping (Bool) -> Void) {
        requestMagicLinkAccessToken(for: token) { [weak self] result in
            self?.handleResult(result, completion: completion)
        }
    }
    
    private func handleResult(_ result: Result<LoginResponse, UserServiceError>, completion: @escaping (Bool) -> Void) {
        switch result {
        case .success(let response):
            guard let email = response.email else {
                completion(false)
                return
            }
            
            Current.userManager.setNewUser(with: response)
            
            createService(params: APIConstants.makeServicePostRequest(email: email), completion: { [weak self] (success, _) in
                guard success else {
                    completion(false)
                    return
                }
                
                self?.getUserProfile(completion: { result in
                    guard let response = try? result.get() else {
                        BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: false))
                        completion(false)
                        return
                    }
                    
                    Current.userManager.setProfile(withResponse: response, updateZendeskIdentity: true)
                    BinkAnalytics.track(OnboardingAnalyticsEvent.userComplete)
                })
                
                Current.rootStateMachine.handleLogin()
                BinkAnalytics.track(OnboardingAnalyticsEvent.serviceComplete)
                BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: true))
                
                completion(true)
            })
        case .failure:
            BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: false))
            completion(false)
        }
    }
}
