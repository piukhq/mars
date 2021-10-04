//
//  LoginView.swift
//  binkapp
//
//  Created by Sean Williams on 21/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @State private var formViewModel: FormViewModel
    private let viewModel: LoginViewViewModel

    init() {
        viewModel = LoginViewViewModel()
        formViewModel = FormViewModel(datasource: viewModel.datasource, title: viewModel.title, description: viewModel.description)
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            BinkFormView(viewModel: formViewModel)
                .onReceive(viewModel.$datasourcePublisher, perform: { datasource in
                    formViewModel = FormViewModel(datasource: datasource, title: viewModel.title, description: viewModel.description)
                })
            if case .none = formViewModel.formInputType {
                BinkButtonsStackView(buttons: [viewModel.continueButton, viewModel.switchLoginTypeButton])
            }
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
