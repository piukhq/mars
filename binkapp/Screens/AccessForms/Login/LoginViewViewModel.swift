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
    
    var primaryButton: BinkGradientButtonSwiftUIView {
        return BinkGradientButtonSwiftUIView(datasource: datasource, isLoading: false, title: L10n.continueButtonTitle, buttonTapped: continueButtonTapped)
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
            self.primaryButton.isLoading = false
            
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
    
    private func showError() {
//        let alert = BinkAlertController(title: L10n.errorTitle, message: L10n.loginError, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: L10n.ok, style: .default))
//        present(alert, animated: true)
//        Alert
    }
    
    private func handleLoginError() {
        Current.userManager.removeUser()
        primaryButton.isLoading = false
        showError()
    }
}
