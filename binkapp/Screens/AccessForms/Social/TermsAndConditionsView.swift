//
//  TermsAndConditionsView.swift
//  binkapp
//
//  Created by Sean Williams on 22/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

enum LoginRequestType {
    case apple(SignInWithAppleRequest)
}

struct TermsAndConditionsView: View {
    private var continueButton: BinkButtonView {
        return BinkButtonView(viewModel: buttonViewModel, title: L10n.continueButtonTitle, buttonTapped: continueButtonTapped, type: .gradient)
    }
    
    @State private var formViewModel: FormViewModel
    private let datasource = FormDataSource(accessForm: .termsAndConditions)
    private let buttonViewModel: ButtonViewModel
    private let requestType: LoginRequestType
    
    init(requestType: LoginRequestType) {
        self.requestType = requestType
        formViewModel = FormViewModel(datasource: datasource, title: L10n.socialTandcsTitle, description: L10n.socialTandcsSubtitle)
        buttonViewModel = ButtonViewModel(datasource: datasource)
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            FormView(viewModel: formViewModel)
            if case .none = formViewModel.formInputType {
                BinkButtonsStackView(buttons: [continueButton])
            }
        })
    }
    
    private func continueButtonTapped() {
        buttonViewModel.isLoading = true
        switch requestType {
        case .apple(let request):
            Current.loginController.loginWithApple(request: request, withPreferences: preferenceValues) { error in
                guard error == nil else {
                    self.handleAuthError()
                    return
                }
            }
        }
    }
    
    private var preferenceValues: [String: String] {
        var params: [String: String] = [:]

        let preferences = datasource.checkboxes.filter { $0.columnKind == .userPreference }
        preferences.forEach {
            if let columnName = $0.columnName {
                params[columnName] = $0.value
            }
        }

        return params
    }
    
    private func handleAuthError() {
        Current.userManager.removeUser()
        buttonViewModel.isLoading = false
        showError()
    }
    
    private func showError() {
        let alert = BinkAlertController(title: L10n.errorTitle, message: L10n.socialTandcsSiwaError, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.ok, style: .default))
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
}

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView(requestType: .apple(SignInWithAppleRequest(authorizationCode: "")))
    }
}
