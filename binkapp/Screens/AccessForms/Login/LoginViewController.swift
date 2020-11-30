//
//  LoginViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 31/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class LoginViewController: BaseFormViewController, UserServiceProtocol {
    private enum Constants {
        static let hyperlinkHeight: CGFloat = 54.0
    }
    
    private lazy var continueButton: BinkGradientButton = {
        let button = BinkGradientButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("continue_button_title".localized, for: .normal)
        button.titleLabel?.font = UIFont.buttonText
        button.addTarget(self, action: .continueButtonTapped, for: .touchUpInside)
        button.isEnabled = false
        button.accessibilityLabel = "Continue"
        button.accessibilityIdentifier = "Continue"
        view.addSubview(button)
        return button
    }()

    init() {
        super.init(title: "login_title".localized, description: "login_subtitle".localized, dataSource: FormDataSource(accessForm: .login))
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackScrollView.add(arrangedSubviews: [hyperlinkButton(title: "login_forgot_password".localized)])
        
        NSLayoutConstraint.activate([
            continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: LayoutHelper.PillButton.widthPercentage),
            continueButton.heightAnchor.constraint(equalToConstant: LayoutHelper.PillButton.height),
            continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -LayoutHelper.PillButton.bottomPadding),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .login)
    }
    
    private func hyperlinkButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let attrString = NSAttributedString(
            string: title,
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.linkUnderlined, .foregroundColor: UIColor.blueAccent]
        )
        button.setAttributedTitle(attrString, for: .normal)
        button.contentHorizontalAlignment = .left
        button.heightAnchor.constraint(equalToConstant: Constants.hyperlinkHeight).isActive = true
        button.addTarget(self, action: .forgotPasswordTapped, for: .touchUpInside)
        return button
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        continueButton.isEnabled = fullFormIsValid
    }
    
    @objc func continueButtonTapped() {
        continueButton.startLoading()
        
        let fields = dataSource.currentFieldValues()

        let loginRequest = LoginRegisterRequest(
            email: fields["email"],
            password: fields["password"]
        )

        login(request: loginRequest) { [weak self] result in
            switch result {
            case .success(let response):
                guard let email = response.email else {
                    self?.handleLoginError()
                    return
                }
                Current.userManager.setNewUser(with: response)
                
                self?.createService(params: APIConstants.makeServicePostRequest(email: email), completion: { (success, _) in
                    guard success else {
                        self?.handleLoginError()
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
                    
                    self?.continueButton.stopLoading()
                    Current.rootStateMachine.handleLogin()
                    BinkAnalytics.track(OnboardingAnalyticsEvent.serviceComplete)
                    BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: true))
                })
            case .failure:
                BinkAnalytics.track(OnboardingAnalyticsEvent.end(didSucceed: false))
                self?.handleLoginError()
            }
        }
    }
    
    @objc func forgotPasswordTapped() {
        let viewController = ViewControllerFactory.makeForgottenPasswordViewController()
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    private func showError() {
        let alert = UIAlertController(title: "error_title".localized, message: "login_error".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }

    private func handleLoginError() {
        Current.userManager.removeUser()
        continueButton.stopLoading()
        showError()
    }
}

extension LoginViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
    
    func formDataSource(_ dataSource: FormDataSource, checkboxUpdated: CheckboxView) {
    }
}

extension LoginViewController: FormCollectionViewCellDelegate {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {}
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField) {}
}

private extension Selector {
    static let continueButtonTapped = #selector(LoginViewController.continueButtonTapped)
    static let forgotPasswordTapped = #selector(LoginViewController.forgotPasswordTapped)
}
