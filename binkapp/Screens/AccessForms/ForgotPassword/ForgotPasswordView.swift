//
//  ForgotPasswordView.swift
//  binkapp
//
//  Created by Sean Williams on 22/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct ForgotPasswordView: View {
    private var continueButton: BinkButtonView {
        return BinkButtonView(viewModel: buttonViewModel, title: L10n.continueButtonTitle, buttonTapped: continueButtonTapped, type: .gradient)
    }

    @State private var formViewModel: FormViewModel
    private let viewModel: ForgotPasswordViewModel
    private let datasource = FormDataSource(accessForm: .forgottenPassword)
    private let buttonViewModel: ButtonViewModel

    init() {
        self.viewModel = ForgotPasswordViewModel(repository: ForgotPasswordRepository(), datasource: datasource)
        formViewModel = FormViewModel(datasource: datasource, title: L10n.loginForgotPassword, description: L10n.forgotPasswordDescription)
        buttonViewModel = ButtonViewModel(datasource: datasource)
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            BinkFormView(viewModel: formViewModel)
            if case .none = formViewModel.pickerType {
                BinkButtonsStackView(buttons: [continueButton])
            }
        })
    }
    
    private func continueButtonTapped() {
        buttonViewModel.isLoading = true
        guard let safeEmail = viewModel.email else { return }
        viewModel.repository.continueButtonTapped(email: safeEmail, completion: {
            let alert = BinkAlertController(title: L10n.loginForgotPassword, message: L10n.fogrotPasswordPopupText, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: L10n.ok, style: .cancel, handler: { _ in
                Current.navigate.back(toRoot: true, animated: true)
            }))
            let navigationRequest = AlertNavigationRequest(alertController: alert)
            Current.navigate.to(navigationRequest)
        })
    }
}
