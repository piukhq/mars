//
//  LoginController.swift
//  binkapp
//
//  Created by Nick Farrant on 06/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import JWTDecode
import UIKit

enum LoginType: String {
    case magicLink = "Magic link"
    case apple = "Apple"
    case password = "Password"
}

class LoginController: UserServiceProtocol {
    func login(with request: LoginRequest, completion: @escaping (UserServiceError?) -> Void) {
        login(request: request) { [weak self] result in
            self?.handleResult(for: .password, result, completion: completion)
        }
    }
    
    func exchangeMagicLinkToken(token: String, withPreferences preferences: [String: String], completion: @escaping (UserServiceError?) -> Void) {
        /// We know that if we don't successfully login, we should fallback to the onboarding screen once loading completes.
        Current.rootStateMachine.startLoading(from: ViewControllerFactory.makeOnboardingViewController())
        
        requestMagicLinkAccessToken(for: token) { [weak self] (result, rawResponse) in
            self?.handleResult(for: .magicLink, result, withPreferences: preferences, completion: { error in
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
    
    func loginWithApple(request: SignInWithAppleRequest, withPreferences preferences: [String: String], completion: @escaping (UserServiceError?) -> Void) {
        authWithApple(request: request) { [weak self] result in
            self?.handleResult(for: .apple, result, withPreferences: preferences, completion: completion)
        }
    }
    
    private func handleResult(for loginType: LoginType, _ result: Result<LoginResponse, UserServiceError>, withPreferences preferences: [String: String]? = nil, completion: @escaping (UserServiceError?) -> Void) {
        /// Remove any current user object regardless of success or failure.
        Current.userManager.removeUser()
        
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
                    MixpanelUtility.track(.login(method: loginType))
                })
                
                Current.rootStateMachine.handleLogin(for: loginType)
                
                BinkAnalytics.track(OnboardingAnalyticsEvent.serviceComplete)
                BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: true))
                                
                completion(nil)
            })
        case .failure(let error):
            if loginType == .magicLink {
                Current.rootStateMachine.stopLoading()
            }
            
            BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: false))
            completion(error)
        }
    }
    
    func decodedEmailAddress(from token: String) -> String? {
        let decodedToken = try? decode(jwt: token)
        return decodedToken?.body["email"] as? String
    }
}

// MARK: - Magic Link Status Screen

extension LoginController {
    func handleMagicLinkCheckInbox(formDataSource: FormDataSource? = nil, token: String? = nil) {
        navigateToStatusScreen(for: .checkInbox, with: formDataSource, token: token)
    }
    
    func handleMagicLinkExpiredToken(token: String) {
        navigateToStatusScreen(for: .expired, token: token)
    }
    
    func handleMagicLinkFailed(token: String) {
        navigateToStatusScreen(for: .failed, token: token)
    }
    
    func displayMagicLinkErrorAlert() {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.errorTitle, message: L10n.magicLinkErrorMessage)
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
    
    private func navigateToStatusScreen(for status: MagicLinkStatus, with dataSource: FormDataSource? = nil, token: String? = nil) {
        var configurationModel: ReusableModalConfiguration
        let decodedEmail = decodedEmailAddress(from: token ?? "")
        var viewController: UIViewController
        
        switch status {
        case .checkInbox:
            let emailAddress = dataSource?.fields.first(where: { $0.fieldCommonName == .email })?.value ?? decodedEmail
            let attributedString = NSMutableAttributedString()
            let attributedTitle = NSAttributedString(string: L10n.checkInboxTitle + "\n", attributes: [NSAttributedString.Key.font: UIFont.headline])
            let attributedBody = NSMutableAttributedString(string: L10n.checkInboxDescription(emailAddress ?? L10n.nilEmailAddress), attributes: [.font: UIFont.bodyTextLarge])
            
            let baseBody = NSString(string: attributedBody.string)
            let emailRange = baseBody.range(of: emailAddress ?? "")
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "NunitoSans-ExtraBold", size: 18.0) ?? UIFont()]
            attributedBody.addAttributes(attributes, range: emailRange)
            
            attributedString.append(attributedTitle)
            attributedString.append(attributedBody)
            
            let availableEmailClients = EmailClient.availableEmailClientsForDevice()
            if availableEmailClients.isEmpty {
                configurationModel = ReusableModalConfiguration(title: "", text: attributedString)
            } else if availableEmailClients.count == 1 {
                let buttonTitle = L10n.openMailButtonTitle(availableEmailClients.first?.rawValue.capitalized ?? "")
                configurationModel = ReusableModalConfiguration(title: "", text: attributedString, primaryButtonTitle: buttonTitle, primaryButtonAction: {
                    availableEmailClients.first?.open()
                })
            } else {
                let buttonTitle = L10n.openMailButtonTitleMultipleClients
                configurationModel = ReusableModalConfiguration(title: "", text: attributedString, primaryButtonTitle: buttonTitle, primaryButtonAction: {
                    let alert = ViewControllerFactory.makeEmailClientsAlertController(availableEmailClients)
                    let navigationRequest = AlertNavigationRequest(alertController: alert)
                    Current.navigate.to(navigationRequest)
                })
            }

            viewController = ViewControllerFactory.makeCheckYourInboxViewController(configuration: configurationModel)
        case .expired:
            configurationModel = ReusableModalConfiguration(title: "", text: ReusableModalConfiguration.makeAttributedString(title: L10n.linkExpiredTitle, description: L10n.linkExpiredDescription), primaryButtonTitle: L10n.retryTitle, primaryButtonAction: {
                // Resend magic link email
                guard let email = decodedEmail else {
                    self.displayMagicLinkErrorAlert()
                    return
                }

                self.requestMagicLink(email: email) { [weak self] (success, _) in
                    guard success else {
                        self?.displayMagicLinkErrorAlert()
                        return
                    }

                    self?.handleMagicLinkCheckInbox(token: token)
                }
            }, secondaryButtonTitle: L10n.cancel) {
                Current.navigate.back(toRoot: true, animated: true)
            }
            
            viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configurationModel)
        case .failed:
            configurationModel = ReusableModalConfiguration(title: "", text: ReusableModalConfiguration.makeAttributedString(title: L10n.somethingWentWrongTitle, description: L10n.somethingWentWrongDescription), primaryButtonTitle: L10n.retryTitle, primaryButtonAction: {
                // Re-attempt token exchange
                guard let token = token else {
                    self.displayMagicLinkErrorAlert()
                    return
                }
                
                self.exchangeMagicLinkToken(token: token, withPreferences: [:]) { [weak self] error in
                    if let error = error {
                        switch error {
                        case .magicLinkExpired:
                            self?.handleMagicLinkExpiredToken(token: token)
                        default:
                            self?.handleMagicLinkFailed(token: token)
                        }
                    }
                }
            }, secondaryButtonTitle: L10n.cancel) {
                Current.navigate.back(toRoot: true, animated: true)
            }
            
            viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configurationModel)
        }
        
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
}
