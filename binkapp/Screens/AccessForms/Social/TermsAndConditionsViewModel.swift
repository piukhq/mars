//
//  TermsAndConditionsViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 13/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class TermsAndConditionsViewModel {
    var requestType: LoginRequestType
    let buttonViewModel: ButtonViewModel
    let datasource = FormDataSource(accessForm: .termsAndConditions)
    
    init(requestType: LoginRequestType) {
        self.requestType = requestType
        buttonViewModel = ButtonViewModel(datasource: datasource, title: L10n.continueButtonTitle)
    }

    func continueButtonTapped() {
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
