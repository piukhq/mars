//
//  LoginViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 31/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

enum MagicLinkStatus {
    case checkInbox
    case expired
    case failed
}

class LoginViewController: BaseFormViewController, UserServiceProtocol {
    private enum Constants {
        static let hyperlinkHeight: CGFloat = 54.0
    }

    private lazy var continueButton: BinkButton = {
        return BinkButton(type: .gradient, title: L10n.continueButtonTitle, enabled: false) { [weak self] in
            self?.continueButtonTapped()
        }
    }()
    
    private lazy var switchLoginTypeButton: BinkButton = {
        BinkButton(type: .plain, title: L10n.loginWithPassword, enabled: true) { [weak self] in
            self?.switchLoginTypeButtonHandler()
        }
    }()
    
    private var magicLinkattributedDescription: NSMutableAttributedString = {
        let attributedDescription = NSMutableAttributedString(string: L10n.magicLinkDescription, attributes: [.font: UIFont.bodyTextLarge])
        let baseDescription = NSString(string: attributedDescription.string)
        let magicLinkRange = baseDescription.range(of: L10n.whatIsMagicLinkHyperlink)
        attributedDescription.addAttributes([.link: "https://help.bink.com/hc/en-gb/categories/360002202520-Frequently-Asked-Questions"], range: magicLinkRange)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "NunitoSans-ExtraBold", size: 18.0) ?? UIFont()]
        let noteRange = baseDescription.range(of: L10n.magicLinkDescriptionNoteHighlight)
        attributedDescription.addAttributes(attributes, range: noteRange)
        return attributedDescription
    }()
    
    private var loginType: AccessForm = .magicLink

    init() {
        super.init(title: L10n.magicLinkTitle, description: "", attributedDescription: magicLinkattributedDescription, dataSource: FormDataSource(accessForm: .magicLink))
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        stackScrollView.add(arrangedSubviews: [hyperlinkButton(title: L10n.loginForgotPassword)])
        
        footerButtons = [
            continueButton, switchLoginTypeButton]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .login)
    }
    
//    private func hyperlinkButton(title: String) -> UIButton {
//        let button = UIButton(type: .custom)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        let attrString = NSAttributedString(
//            string: title,
//            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.linkUnderlined, .foregroundColor: UIColor.blueAccent]
//        )
//        button.setAttributedTitle(attrString, for: .normal)
//        button.contentHorizontalAlignment = .left
//        button.heightAnchor.constraint(equalToConstant: Constants.hyperlinkHeight).isActive = true
//        button.addTarget(self, action: .forgotPasswordTapped, for: .touchUpInside)
//        return button
//    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        continueButton.enabled = fullFormIsValid
    }
    
    @objc func continueButtonTapped() {
        continueButton.toggleLoading(isLoading: true)
        
        if loginType == .emailPassword {
            performLogin()
        }
        
        if loginType == .magicLink {
            performMagicLinkRequest()
        }
    }
    
    private func switchLoginTypeButtonHandler() {
        loginType = loginType == .magicLink ? .emailPassword : .magicLink
        let emailAddress = dataSource.fields.first(where: { $0.fieldCommonName == .email })?.value
        let prefilledValues = FormDataSource.PrefilledValue(commonName: .email, value: emailAddress)
        dataSource = FormDataSource(accessForm: loginType, prefilledValues: [prefilledValues])
        dataSource.delegate = self
        formValidityUpdated(fullFormIsValid: dataSource.fullFormIsValid)
        switchLoginTypeButton.setTitle(loginType == .magicLink ? L10n.loginWithPassword : L10n.emailMagicLink)
        
        if loginType == .magicLink {
            titleLabel.text = L10n.magicLinkTitle
            textView.attributedText = magicLinkattributedDescription
            descriptionLabel.text = nil
        } else {
            titleLabel.text = L10n.loginTitle
            textView.text = nil
            descriptionLabel.text = L10n.loginSubtitle
        }
    }
    
    @objc func forgotPasswordTapped() {
        let viewController = ViewControllerFactory.makeForgottenPasswordViewController()
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    private func performLogin() {
        let fields = dataSource.currentFieldValues()
        
        let loginRequest: LoginRegisterRequest
        
        let customBundleClientEnabled = Current.userDefaults.bool(forDefaultsKey: .allowCustomBundleClientOnLogin)
        
        if !Current.isReleaseTypeBuild && customBundleClientEnabled {
            loginRequest = LoginRegisterRequest(
                email: fields["email"],
                password: fields["password"],
                clientID: fields["client id"] ?? "",
                bundleID: fields["bundle id"] ?? ""
            )
        } else {
            loginRequest = LoginRegisterRequest(
                email: fields["email"],
                password: fields["password"]
            )
        }

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
                    
                    self?.continueButton.toggleLoading(isLoading: false)
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
    
    private func performMagicLinkRequest() {
        let fields = dataSource.currentFieldValues()

        // TODO: This should take a request object
        requestMagicLink(email: fields["email"]!) { (success, error) in
            if let error = error {
                // TODO: Handle error
                print(error.localizedDescription)
            }
            
            self.navigateToStatusScreen(for: .checkInbox)
        }
    }
    
    private func navigateToStatusScreen(for status: MagicLinkStatus) {
        // TODO: Can we move this logic elsewhere?
        var configurationModel: ReusableModalConfiguration
        
        switch status {
        case .checkInbox:
            let emailAddress = dataSource.fields.first(where: { $0.fieldCommonName == .email })?.value
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
        continueButton.toggleLoading(isLoading: false)
        Current.navigate.to(navigationRequest)
    }
    
    private func showError() {
        let alert = BinkAlertController(title: L10n.errorTitle, message: L10n.loginError, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.ok, style: .default))
        present(alert, animated: true)
    }

    private func handleLoginError() {
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

extension LoginViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
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
