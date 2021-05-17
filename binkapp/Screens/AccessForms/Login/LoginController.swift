//
//  LoginController.swift
//  binkapp
//
//  Created by Nick Farrant on 06/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class LoginController: UserServiceProtocol {
    func login(with request: LoginRegisterRequest, completion: @escaping (UserServiceError?) -> Void) {
        login(request: request) { [weak self] result in
            self?.handleResult(result, completion: completion)
        }
    }
    
    func exchangeMagicLinkToken(token: String, completion: @escaping (UserServiceError?) -> Void) {
        Current.rootStateMachine.startLoading(from: ViewControllerFactory.makeOnboardingViewController())
        requestMagicLinkAccessToken(for: token) { [weak self] (result, rawResponse) in
            self?.handleResult(result, completion: { error in
                if let error = error {
                    if rawResponse?.urlResponse?.statusCode == 401 {
                        completion(.magicLinkExpired)
                        return
                    }
                    completion(error)
                    return
                }
                completion(nil)
            })
        }
    }
    
    private func handleResult(_ result: Result<LoginResponse, UserServiceError>, completion: @escaping (UserServiceError?) -> Void) {
        switch result {
        case .success(let response):
            guard let email = response.email else {
                completion(.failedToLogin)
                return
            }
        
            Current.userManager.setNewUser(with: response)
            
            createService(params: APIConstants.makeServicePostRequest(email: email), completion: { [weak self] (success, _) in
                guard success else {
                    completion(.failedToCreateService)
                    return
                }
                
                self?.getUserProfile(completion: { result in
                    guard let response = try? result.get() else {
                        BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: false))
                        completion(.failedToGetUserProfile)
                        return
                    }
                    
                    Current.userManager.setProfile(withResponse: response, updateZendeskIdentity: true)
                    BinkAnalytics.track(OnboardingAnalyticsEvent.userComplete)
                })
                
                Current.rootStateMachine.handleLogin()
                BinkAnalytics.track(OnboardingAnalyticsEvent.serviceComplete)
                BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: true))
                
                completion(nil)
            })
        case .failure(let error):
            Current.rootStateMachine.stopLoading()
            BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: false))
            completion(error)
        }
    }
}

// MARK: - Magic Link Status Screen

extension LoginController {
    func handleMagicLinkCheckInbox(formDataSource: FormDataSource) {
        navigateToStatusScreen(for: .checkInbox, with: formDataSource)
    }
    
    func handleMagicLinkExpiredToken() {
        navigateToStatusScreen(for: .expired)
    }
    
    func handleMagicLinkFailed() {
        navigateToStatusScreen(for: .failed)
    }
    
    private func navigateToStatusScreen(for status: MagicLinkStatus, with dataSource: FormDataSource? = nil) {
        var configurationModel: ReusableModalConfiguration
        
        switch status {
        case .checkInbox:
            let emailAddress = dataSource?.fields.first(where: { $0.fieldCommonName == .email })?.value
            let attributedString = NSMutableAttributedString()
            let attributedTitle = NSAttributedString(string: L10n.checkInboxTitle + "\n", attributes: [NSAttributedString.Key.font: UIFont.headline])
            let attributedBody = NSMutableAttributedString(string: L10n.checkInboxDescription(emailAddress ?? L10n.nilEmailAddress), attributes: [.font: UIFont.bodyTextLarge])
            
            let baseBody = NSString(string: attributedBody.string)
            let noteRange = baseBody.range(of: L10n.magicLinkDescriptionNoteHighlight)
            let emailRange = baseBody.range(of: emailAddress ?? "")
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "NunitoSans-ExtraBold", size: 18.0) ?? UIFont()]
            attributedBody.addAttributes(attributes, range: noteRange)
            attributedBody.addAttributes(attributes, range: emailRange)
            
            attributedString.append(attributedTitle)
            attributedString.append(attributedBody)
            configurationModel = ReusableModalConfiguration(title: "", text: attributedString)
        case .expired:
            configurationModel = ReusableModalConfiguration(title: "", text: ReusableModalConfiguration.makeAttributedString(title: L10n.linkExpiredTitle, description: L10n.linkExpiredDescription), primaryButtonTitle: L10n.retryTitle, primaryButtonAction: {
                Current.navigate.back()
            }, secondaryButtonTitle: L10n.cancel) {
                Current.navigate.back(toRoot: true, animated: true)
            }
        case .failed:
            configurationModel = ReusableModalConfiguration(title: "", text: ReusableModalConfiguration.makeAttributedString(title: L10n.somethingWentWrongTitle, description: L10n.somethingWentWrongDescription), primaryButtonTitle: L10n.retryTitle, primaryButtonAction: {
                Current.navigate.back()
            }, secondaryButtonTitle: L10n.cancel) {
                Current.navigate.back(toRoot: true, animated: true)
            }
        }
        
        let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configurationModel)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
}
