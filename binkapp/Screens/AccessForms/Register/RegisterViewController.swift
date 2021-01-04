//
//  RegisterViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 03/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class RegisterViewController: BaseFormViewController, UserServiceProtocol {
    private lazy var continueButton: BinkButton = {
        return BinkButton(type: .gradient, title: "continue_button_title".localized, enabled: false) { [weak self] in
            self?.continueButtonTapped()
        }
    }()
        
    init() {
        super.init(title: "register_title".localized, description: "register_subtitle".localized, dataSource: FormDataSource(accessForm: .register))
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
        setScreenName(trackedScreen: .register)
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        continueButton.enabled = fullFormIsValid
    }
    
    @objc func continueButtonTapped() {
        let fields = dataSource.currentFieldValues()
                
        let loginRequest = LoginRegisterRequest(
            email: fields["email"],
            password: fields["password"]
        )
        
        let preferenceCheckboxes = dataSource.checkboxes.filter { $0.columnKind == .userPreference }
                
        continueButton.toggleLoading(isLoading: true)

        registerUser(request: loginRequest) { [weak self] result in
            switch result {
            case .success(let response):
                guard let email = response.email else {
                    self?.handleRegistrationError()
                    return
                }
                Current.userManager.setNewUser(with: response)
                
                self?.createService(params: APIConstants.makeServicePostRequest(email: email), completion: { (success, _) in
                    guard success else {
                        self?.handleRegistrationError()
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
                self?.handleRegistrationError()
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
        
        setPreferences(params: params)
    }
    
    private func showError() {
        let alert = UIAlertController(title: "error_title".localized, message: "register_failed".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }

    private func handleRegistrationError() {
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

extension RegisterViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
    
    func formDataSource(_ dataSource: FormDataSource, manualValidate field: FormField) -> Bool {
        // Make sure this field is the confirmPassword field
        guard field.fieldType == .confirmPassword, let passwordToCheckAgainst = dataSource.currentFieldValues()["password"] else {
            return false
        }
        
        return field.value == passwordToCheckAgainst
    }
}

extension RegisterViewController: FormCollectionViewCellDelegate {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {}
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField) {}
}

private extension Selector {
    static let continueButtonTapped = #selector(RegisterViewController.continueButtonTapped)
}
