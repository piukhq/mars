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
    
    private lazy var hyperlinkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let attrString = NSAttributedString(
            string: L10n.loginForgotPassword,
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.linkUnderlined, .foregroundColor: UIColor.blueAccent]
        )
        button.setAttributedTitle(attrString, for: .normal)
        button.contentHorizontalAlignment = .left
        button.heightAnchor.constraint(equalToConstant: Constants.hyperlinkHeight).isActive = true
        button.addTarget(self, action: .forgotPasswordTapped, for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private var magicLinkattributedDescription: NSMutableAttributedString = {
        let attributedDescription = NSMutableAttributedString(string: L10n.magicLinkDescription, attributes: [.font: UIFont.bodyTextLarge])
        let baseDescription = NSString(string: attributedDescription.string)
        let magicLinkRange = baseDescription.range(of: L10n.whatIsMagicLinkHyperlink)
        attributedDescription.addAttributes([.link: "https://help.bink.com/hc/en-gb/articles/4404303824786"], range: magicLinkRange)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "NunitoSans-ExtraBold", size: 18.0) ?? UIFont()]
        let noteRange = baseDescription.range(of: L10n.magicLinkDescriptionNoteHighlight)
        attributedDescription.addAttributes(attributes, range: noteRange)
        return attributedDescription
    }()
    
    override func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let viewController = ViewControllerFactory.makeWebViewController(urlString: URL.absoluteString)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
        return false
    }
    
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
        stackScrollView.add(arrangedSubviews: [hyperlinkButton])
        footerButtons = [continueButton, switchLoginTypeButton]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .login)
    }
    
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
            hyperlinkButton.isHidden = true
        } else {
            titleLabel.text = L10n.loginTitle
            textView.text = nil
            descriptionLabel.text = L10n.loginSubtitle
            hyperlinkButton.isHidden = false
        }
    }
    
    @objc func forgotPasswordTapped() {
        let viewController = ViewControllerFactory.makeForgottenPasswordViewController()
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    private func performLogin() {
        let fields = dataSource.currentFieldValues()
        
        let loginRequest: LoginRequest
        
        let customBundleClientEnabled = Current.userDefaults.bool(forDefaultsKey: .allowCustomBundleClientOnLogin)
        
        if !Current.isReleaseTypeBuild && customBundleClientEnabled {
            loginRequest = LoginRequest(
                email: fields["email"],
                password: fields["password"],
                clientID: fields["client id"] ?? "",
                bundleID: fields["bundle id"] ?? ""
            )
        } else {
            loginRequest = LoginRequest(
                email: fields["email"],
                password: fields["password"]
            )
        }
        
        Current.loginController.login(with: loginRequest) { error in
            if error != nil {
                self.handleLoginError()
                return
            }
        }
    }
    
    private func performMagicLinkRequest() {
        let fields = dataSource.currentFieldValues()
        guard let email = fields["email"] else {
            Current.loginController.displayMagicLinkErrorAlert()
            return
        }
        
        requestMagicLink(email: email) { [weak self] (success, _) in
            guard let self = self else { return }
            self.continueButton.toggleLoading(isLoading: false)
            
            guard success else {
                Current.loginController.displayMagicLinkErrorAlert()
                return
            }
            
            Current.loginController.handleMagicLinkCheckInbox(formDataSource: self.dataSource)
        }
    }
    
    func presentLoginIssuesScreen() {
        let viewController = ViewControllerFactory.makeWebViewController(urlString: "https://help.bink.com/hc/en-gb/categories/360002202520-Frequently-Asked-Questions")
        let request = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(request)
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
