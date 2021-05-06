//
//  DeepLinkUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 05/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

class DeepLinkUtility {
    enum DeepLinkType: String {
        case magicLink = "magic"
    }
    
    func handleDeepLink(for url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        guard let host = urlComponents.host, let deepLinkType = DeepLinkType(rawValue: host) else { return }
        
        switch deepLinkType {
        case .magicLink:
            handleMagicLinkDeepLink(urlComponents: urlComponents)
        }
    }
    
    private func handleMagicLinkDeepLink(urlComponents: URLComponents) {
        guard let queryItems = urlComponents.queryItems else { return }
        
        for item in queryItems {
            if item.name == "token", let token = item.value {
                let loginController = LoginController()
                loginController.exchangeMagicLinkToken(token: token)
            }
        }
    }
}

// TODO: Move this, and bring standard login into it also
class LoginController: UserServiceProtocol {
    func exchangeMagicLinkToken(token: String) {
        requestMagicLinkAccessToken(for: token) { [weak self] result in
            self?.handleResult(result)
        }
    }
    
    private func handleResult(_ result: Result<LoginResponse, UserServiceError>) {
        switch result {
        case .success(let response):
            // TODO: Pass error back to in completion
            guard let email = response.email else { return }
            
            Current.userManager.setNewUser(with: response)
            
            // TODO: This never gets called?
            createService(params: APIConstants.makeServicePostRequest(email: email), completion: { [weak self] (success, _) in
                // TODO: Pass error back in completion
                guard success else { return }

                self?.getUserProfile(completion: { result in
                    guard let response = try? result.get() else {
                        BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: false))
                        return
                    }
                    Current.userManager.setProfile(withResponse: response, updateZendeskIdentity: true)
                    BinkAnalytics.track(OnboardingAnalyticsEvent.userComplete)
                })

                // TODO: Pass success back in completion
//                            self?.continueButton.toggleLoading(isLoading: false)
                Current.rootStateMachine.handleLogin()
                BinkAnalytics.track(OnboardingAnalyticsEvent.serviceComplete)
                BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: true))
            })
        
        case .failure(let error):
            print("Handle error: \(error.localizedDescription)")
        }
    }
}
