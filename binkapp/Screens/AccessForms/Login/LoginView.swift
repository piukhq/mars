//
//  LoginView.swift
//  binkapp
//
//  Created by Sean Williams on 21/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    var continueButton: BinkButtonView {
        return BinkButtonView(viewModel: viewModel.continueButtonViewModel, buttonTapped: viewModel.continueButtonTapped, type: .gradient)
    }
    
    var switchLoginTypeButton: BinkButtonView {
        return BinkButtonView(viewModel: viewModel.switchLoginTypeButtonViewModel, buttonTapped: viewModel.switchLoginTypeButtonHandler, type: .plain, alwaysEnabled: true)
    }
    
    @State private var formViewModel: FormViewModel
    private let viewModel = LoginViewModel()

    init() {
        formViewModel = FormViewModel(datasource: viewModel.datasource, title: viewModel.title, description: viewModel.description)
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            FormView(viewModel: formViewModel)
                .onReceive(viewModel.$datasourcePublisher, perform: { datasource in
                    formViewModel = FormViewModel(datasource: datasource, title: viewModel.title, description: viewModel.description)
                })
            if case .none = formViewModel.formInputType {
                BinkButtonsStackView(buttons: [continueButton, switchLoginTypeButton])
            }
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
