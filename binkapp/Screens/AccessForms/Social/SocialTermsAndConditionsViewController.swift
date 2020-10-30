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

    private lazy var continueButton: BinkGradientButton = {
        let button = BinkGradientButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("continue_button_title".localized, for: .normal)
        button.titleLabel?.font = UIFont.buttonText
        button.addTarget(self, action: .continueButtonTapped, for: .touchUpInside)
        button.isEnabled = false
        view.addSubview(button)
        return button
    }()

    private let requestType: SocialLoginRequestType
    
    init(requestType: SocialLoginRequestType) {
        self.requestType = requestType
        super.init(title: "social_tandcs_title".localized, description: "social_tandcs_subtitle".localized, dataSource: FormDataSource(accessForm: .socialTermsAndConditions))
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSLayoutConstraint.activate([
            continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: LayoutHelper.PillButton.widthPercentage),
            continueButton.heightAnchor.constraint(equalToConstant: LayoutHelper.PillButton.height),
            continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -LayoutHelper.PillButton.bottomPadding),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        //TODO: remove this if we don't need to display the old screen at all
        //        let lastView = stackScrollView.arrangedSubviews.last
        //        stackScrollView.add(arrangedSubview: message)
        //
        //        if let lastView = lastView {
        //            stackScrollView.customPadding(18.0, after: lastView)
        //        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .socialTermsAndConditions)
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        continueButton.isEnabled = fullFormIsValid
    }
    
    @objc func continueButtonTapped() {
        let preferenceCheckboxes = dataSource.checkboxes.filter { $0.columnKind == .userPreference }
        continueButton.startLoading()
        
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
                    self?.continueButton.stopLoading()
                    
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
                    self?.continueButton.stopLoading()
                    
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

        var params = [String: String]()

        checkboxes.forEach {
            if let columnName = $0.columnName {
                params[columnName] = $0.value
            }
        }

        guard params.count > 0 else { return }

        // We don't worry about whether this was successful or not
        setPreferences(params: params)
    }
    
    private func showError() {
        let message: String
        
        switch requestType {
        case .apple(_):
            message = "social_tandcs_siwa_error".localized
        case .facebook(_):
            message = "social_tandcs_facebook_error".localized
        }
        
        let alert = UIAlertController(title: "error_title".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }

    private func handleAuthError() {
        Current.userManager.removeUser()
        continueButton.stopLoading()
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

private extension Selector {
    static let continueButtonTapped = #selector(SocialTermsAndConditionsViewController.continueButtonTapped)
}
