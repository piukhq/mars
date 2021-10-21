//
//  LoginViewViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 21/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit
import SwiftUI

final class LoginViewModel: UserServiceProtocol, ObservableObject {
    @Published var datasourcePublisher: FormDataSource

    private var loginType: AccessForm = .magicLink
    var continueButtonViewModel: ButtonViewModel
    var switchLoginTypeButtonViewModel: ButtonViewModel
    var title = L10n.magicLinkTitle
    var description = L10n.magicLinkDescription
    var datasource: FormDataSource {
        didSet {
            datasourcePublisher = datasource
        }
    }
    
    init() {
        self.datasource = FormDataSource(accessForm: .magicLink)
        self.datasourcePublisher = datasource
        self.continueButtonViewModel = ButtonViewModel(datasource: datasource, title: L10n.continueButtonTitle)
        self.switchLoginTypeButtonViewModel = ButtonViewModel(datasource: datasource, title: L10n.loginWithPassword)
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
            self.displayMagicLinkErrorAlert()
            return
        }
        
        requestMagicLink(email: email) { [weak self] (success, _) in
            guard let self = self else { return }
            guard success else {
                self.displayMagicLinkErrorAlert()
                return
            }
            
            Current.loginController.handleMagicLinkCheckInbox(formDataSource: self.datasource)
            self.continueButtonViewModel.isLoading = false
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
    
    func switchLoginTypeButtonHandler() {
        loginType = loginType == .magicLink ? .emailPassword : .magicLink
        let emailAddress = datasource.fields.first(where: { $0.fieldCommonName == .email })?.value
        let prefilledValues = FormDataSource.PrefilledValue(commonName: .email, value: emailAddress)
        datasource = FormDataSource(accessForm: loginType, prefilledValues: [prefilledValues])
        continueButtonViewModel.datasource = datasource
        switchLoginTypeButtonViewModel.datasource = datasource
        datasource.checkFormValidity()
        
        switchLoginTypeButtonViewModel.title = loginType == .magicLink ? L10n.loginWithPassword : L10n.emailMagicLink
        
        if loginType == .magicLink {
            title = L10n.magicLinkTitle
            description = L10n.magicLinkDescription
        } else {
            title = L10n.loginTitle
            description = L10n.loginSubtitle
        }
    }
    
    private func showError() {
        let alert = BinkAlertController(title: L10n.errorTitle, message: L10n.loginError, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.ok, style: .default))
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
    
    private func displayMagicLinkErrorAlert() {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.errorTitle, message: L10n.magicLinkErrorMessage) {
            self.continueButtonViewModel.isLoading = false
        }
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
    
    private func handleLoginError() {
        Current.userManager.removeUser()
        continueButtonViewModel.isLoading = false
        showError()
    }
}
