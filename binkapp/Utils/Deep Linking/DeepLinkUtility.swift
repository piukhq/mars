//
//  DeepLinkUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 05/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

class DeepLinkUtility: UserServiceProtocol {
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
                // TODO: Use token to exchange for access token
                requestMagicLinkAccessToken(for: token) { [weak self] result in
                    switch result {
                    case .success(let response):
                        // TODO: Pass error back to in completion
                        guard let email = response.email else { return }
                        
                        Current.userManager.setNewUser(with: response)
                        
                        // TODO: This never gets called?
                        self?.createService(params: APIConstants.makeServicePostRequest(email: email), completion: { (success, _) in
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
        }
    }
}

class LoginController {
    
}
