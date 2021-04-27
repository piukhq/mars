//
//  SocialTermsAndConditionsViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 03/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

enum SocialLoginRequestType {
    case facebook(FacebookRequest)
    case apple(SignInWithAppleRequest)
}

class SocialTermsAndConditionsViewController: BaseFormViewController, UserServiceProtocol {
    private lazy var continueButton: BinkButton = {
        return BinkButton(type: .gradient, title: L10n.continueButtonTitle, enabled: false) { [weak self] in
            self?.continueButtonTapped()
        }
    }()

    private let requestType: SocialLoginRequestType
    
    init(requestType: SocialLoginRequestType) {
        self.requestType = requestType
        super.init(title: L10n.socialTandcsTitle, description: L10n.socialTandcsSubtitle, dataSource: FormDataSource(accessForm: .socialTermsAndConditions))
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        footerButtons = [continueButton]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .socialTermsAndConditions)
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        continueButton.enabled = fullFormIsValid
    }
    
    @objc func continueButtonTapped() {
        let preferenceCheckboxes = dataSource.checkboxes.filter { $0.columnKind == .userPreference }
        continueButton.toggleLoading(isLoading: true)
        
        switch requestType {
        case .facebook(let request):
            loginWithFacebook(request: request, preferenceCheckboxes: preferenceCheckboxes)
        case .apple(let request):
            loginWithApple(request: request, preferenceCheckboxes: preferenceCheckboxes)
        }
    }
    
    // FIXME: To avoid the code duplicate below, in future we need to build the Facebook and Apple request objects from a common object type
    
    private func loginWithFacebook(request: FacebookRequest, preferenceCheckboxes: [CheckboxView]) {
        authWithFacebook(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                guard let email = response.email else {
                    self?.handleAuthError()
                    return
                }
                Current.userManager.setNewUser(with: response)
                
                self?.createService(params: APIConstants.makeServicePostRequest(email: email)) { (success, _) in
                    guard success else {
                        self?.handleAuthError()
                        return
                    }
                    
                    self?.getUserProfile(completion: { result in
                        guard let response = try? result.get() else {
                            BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: false))
                            return
                        }
                        Current.userManager.setProfile(withResponse: response, updateZendeskIdentity: true)
                        BinkAnalytics.track(OnboardingAnalyticsEvent.userComplete)
                    })
                    
                    Current.rootStateMachine.handleLogin()
                    self?.updatePreferences(checkboxes: preferenceCheckboxes)
                    self?.continueButton.toggleLoading(isLoading: false)
                    
                    BinkAnalytics.track(OnboardingAnalyticsEvent.serviceComplete)
                    BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: true))
                }
            case .failure:
                BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: false))
                self?.handleAuthError()
            }
        }
    }
    
    private func loginWithApple(request: SignInWithAppleRequest, preferenceCheckboxes: [CheckboxView]) {
        authWithApple(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                guard let email = response.email else {
                    self?.handleAuthError()
                    return
                }
                Current.userManager.setNewUser(with: response)
                
                self?.createService(params: APIConstants.makeServicePostRequest(email: email), completion: { (success, _) in
                    guard success else {
                        self?.handleAuthError()
                        return
                    }
                    
                    self?.getUserProfile(completion: { result in
                        guard let response = try? result.get() else {
                            BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: false))
                            return
                        }
                        Current.userManager.setProfile(withResponse: response, updateZendeskIdentity: true)
                        BinkAnalytics.track(OnboardingAnalyticsEvent.userComplete)
                    })
                    
                    Current.rootStateMachine.handleLogin()
                    self?.updatePreferences(checkboxes: preferenceCheckboxes)
                    self?.continueButton.toggleLoading(isLoading: false)
                    
                    BinkAnalytics.track(OnboardingAnalyticsEvent.serviceComplete)
                    BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: true))
                })
            case .failure:
                BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: false))
                self?.handleAuthError()
            }
        }
    }
    
    func updatePreferences(checkboxes: [CheckboxView]) {
        var params: [String: String] = [:]

        checkboxes.forEach {
            if let columnName = $0.columnName {
                params[columnName] = $0.value
            }
        }

        guard !params.isEmpty else { return }

        // We don't worry about whether this was successful or not
        setPreferences(params: params)
    }
    
    private func showError() {
        let message: String
        
        switch requestType {
        case .apple:
            message = L10n.socialTandcsSiwaError
        case .facebook:
            message = L10n.socialTandcsFacebookError
        }
        
        let alert = BinkAlertController(title: L10n.errorTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.ok, style: .default))
        present(alert, animated: true)
    }

    private func handleAuthError() {
        Current.userManager.removeUser()
        continueButton.toggleLoading(isLoading: false)
        showError()
    }
    
    override func checkboxView(_ checkboxView: CheckboxView, didTapOn URL: URL) {
        let viewController = ViewControllerFactory.makeWebViewController(urlString: URL.absoluteString)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
}

extension SocialTermsAndConditionsViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
}

extension SocialTermsAndConditionsViewController: FormCollectionViewCellDelegate {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {}
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField) {}
}
