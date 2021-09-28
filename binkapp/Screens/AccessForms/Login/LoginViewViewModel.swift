//
//  LoginViewViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 21/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit
import SwiftUI

final class LoginViewViewModel: UserServiceProtocol, ObservableObject {
    lazy var continueButton: BinkButtonView = {
        return BinkButtonView(viewModel: buttonViewModel, title: L10n.continueButtonTitle, buttonTapped: continueButtonTapped, type: .gradient)
    }()
    
    lazy var switchLoginTypeButton: BinkButtonView = {
        return BinkButtonView(viewModel: buttonViewModel, title: L10n.loginWithPassword, buttonTapped: switchLoginTypeButtonHandler, type: .plain, alwaysEnabled: true)
    }()
    
    @Published var datasourcePublisher: FormDataSource
    var datasource: FormDataSource {
        didSet {
            datasourcePublisher = datasource
        }
    }
    private var buttonViewModel: ButtonViewModel
    private var loginType: AccessForm = .magicLink
    var title = L10n.magicLinkTitle
    var description = L10n.magicLinkDescription
    
    init() {
        self.datasource = FormDataSource(accessForm: .magicLink)
        self.datasourcePublisher = datasource
        self.buttonViewModel = ButtonViewModel(datasource: datasource)
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
            guard success else {
                Current.loginController.displayMagicLinkErrorAlert()
                return
            }
            
            Current.loginController.handleMagicLinkCheckInbox(formDataSource: self.datasource)
            self.buttonViewModel.isLoading = false
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
        loginType = loginType == .magicLink ? .emailPassword : .magicLink
        let emailAddress = datasource.fields.first(where: { $0.fieldCommonName == .email })?.value
        let prefilledValues = FormDataSource.PrefilledValue(commonName: .email, value: emailAddress)
        datasource = FormDataSource(accessForm: loginType, prefilledValues: [prefilledValues])
        buttonViewModel.datasource = datasource
        datasource.checkFormValidity()
        
        switchLoginTypeButton.title = loginType == .magicLink ? L10n.loginWithPassword : L10n.emailMagicLink
        
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
    
    private func handleLoginError() {
        Current.userManager.removeUser()
        buttonViewModel.isLoading = false
        showError()
    }
}
