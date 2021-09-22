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
        return BinkButtonView(datasource: datasource, viewModel: buttonViewModel, title: L10n.continueButtonTitle, buttonTapped: continueButtonTapped, type: .gradient)
    }
    
    @State private var formViewModel: FormViewModel
    @State private var showingAlert = false
    private let viewModel: ForgotPasswordViewModel
    private let datasource = FormDataSource(accessForm: .forgottenPassword)
    private let buttonViewModel = ButtonViewModel()
    var popToRoot: () -> Void = {}

    init() {
        self.viewModel = ForgotPasswordViewModel(repository: ForgotPasswordRepository(), datasource: datasource)
        formViewModel = FormViewModel(datasource: datasource, title: L10n.loginForgotPassword, description: L10n.forgotPasswordDescription)
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            BinkFormView(viewModel: formViewModel)
            if case .none = formViewModel.pickerType {
                BinkButtonsStackView(buttons: [continueButton])
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text(L10n.loginForgotPassword), message: Text(L10n.fogrotPasswordPopupText), dismissButton: .cancel(Text(L10n.ok), action: {
                            buttonViewModel.isLoading = false
                            popToRoot()
                        }))
                    }
            }
        })
    }
    
    private func continueButtonTapped() {
        guard let safeEmail = viewModel.email else { return }
        viewModel.repository.continueButtonTapped(email: safeEmail, completion: {
            showingAlert = true
        })
    }
}


final class ForgotPasswordViewHostingController: UIHostingController<ForgotPasswordView> {
    init() {
        super.init(rootView: ForgotPasswordView())
        rootView.popToRoot = popToRoot
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func popToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
}
