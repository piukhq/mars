//
//  LoginViewViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 21/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

final class LoginViewViewModel: UserServiceProtocol {
    private var loginType: AccessForm = .magicLink
    private var datasource: FormDataSource
    
    var continueButton: BinkGradientButtonSwiftUIView {
        return BinkGradientButtonSwiftUIView(datasource: datasource, title: L10n.continueButtonTitle, buttonTapped: continueButtonTapped, type: .gradient)
    }
    
    var switchLoginTypeButton: BinkGradientButtonSwiftUIView {
        return BinkGradientButtonSwiftUIView(datasource: datasource, enabled: true, title: L10n.loginWithPassword, buttonTapped: switchLoginTypeButtonHandler, type: .plain)
    }
    
    init(datasource: FormDataSource) {
        self.datasource = datasource
    }

    func continueButtonTapped() {
        if loginType == .emailPassword {
            performLogin()
        }
        
        if loginType == .magicLink {
            performMagicLinkRequest()
        }
    }
    
    private func performMagicLinkRequest() {
        let fields = datasource.currentFieldValues()
        guard let email = fields["email"] else {
            Current.loginController.displayMagicLinkErrorAlert()
            return
        }
        
        requestMagicLink(email: email) { [weak self] (success, _) in
            guard let self = self else { return }
            self.continueButton.isLoading = false
            
            guard success else {
                Current.loginController.displayMagicLinkErrorAlert()
                return
            }
            
            Current.loginController.handleMagicLinkCheckInbox(formDataSource: self.datasource)
        }
    }
    
    private func performLogin() {
        let fields = datasource.currentFieldValues()
        
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
    
    private func switchLoginTypeButtonHandler() {
//        loginType = loginType == .magicLink ? .emailPassword : .magicLink
//        let emailAddress = dataSource.fields.first(where: { $0.fieldCommonName == .email })?.value
//        let prefilledValues = FormDataSource.PrefilledValue(commonName: .email, value: emailAddress)
//        dataSource = FormDataSource(accessForm: loginType, prefilledValues: [prefilledValues])
//        dataSource.delegate = self
////        formValidityUpdated(fullFormIsValid: dataSource.fullFormIsValid)
//        switchLoginTypeButton.setTitle(loginType == .magicLink ? L10n.loginWithPassword : L10n.emailMagicLink)
//        
//        if loginType == .magicLink {
//            titleLabel.text = L10n.magicLinkTitle
//            textView.attributedText = magicLinkattributedDescription
//            descriptionLabel.text = nil
//            hyperlinkButton.isHidden = true
//        } else {
//            titleLabel.text = L10n.loginTitle
//            textView.text = nil
//            descriptionLabel.text = L10n.loginSubtitle
//            hyperlinkButton.isHidden = false
//        }
    }
    
    private func showError() {
//        let alert = BinkAlertController(title: L10n.errorTitle, message: L10n.loginError, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: L10n.ok, style: .default))
//        present(alert, animated: true)
//        Alert
    }
    
    private func handleLoginError() {
        Current.userManager.removeUser()
        continueButton.isLoading = false
        showError()
    }
}
