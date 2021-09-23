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
    @State private var showingAlert = false
    private let datasource = FormDataSource(accessForm: .termsAndConditions)
    private let buttonViewModel: ButtonViewModel
    private let requestType: LoginRequestType
    private var errorMessage: String {
        let message: String
        switch requestType {
        case .apple:
            message = L10n.socialTandcsSiwaError
        }
        return message
    }
    
    init(requestType: LoginRequestType) {
        self.requestType = requestType
        formViewModel = FormViewModel(datasource: datasource, title: L10n.socialTandcsTitle, description: L10n.socialTandcsSubtitle)
        buttonViewModel = ButtonViewModel(datasource: datasource)
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            BinkFormView(viewModel: formViewModel)
            if case .none = formViewModel.pickerType {
                BinkButtonsStackView(buttons: [continueButton])
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text(L10n.errorTitle), message: Text(errorMessage), dismissButton: .default(Text(L10n.ok), action: {
                            buttonViewModel.isLoading = false
                            showingAlert = false
                        }))
                    }
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
        showingAlert = true
    }
}

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView(requestType: .apple(SignInWithAppleRequest(authorizationCode: "")))
    }
}
