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
        return BinkButtonView(viewModel: viewModel.buttonViewModel, title: L10n.continueButtonTitle, buttonTapped: viewModel.continueButtonTapped, type: .gradient)
    }

    @State private var formViewModel: FormViewModel
    private let viewModel: ForgotPasswordViewModel
    private let datasource = FormDataSource(accessForm: .forgottenPassword)

    init() {
        self.viewModel = ForgotPasswordViewModel(repository: ForgotPasswordRepository(), datasource: datasource)
        formViewModel = FormViewModel(datasource: datasource, title: L10n.loginForgotPassword, description: L10n.forgotPasswordDescription)
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            FormView(viewModel: formViewModel)
            if case .none = formViewModel.formInputType {
                BinkButtonsStackView(buttons: [continueButton])
            }
        })
    }
}
