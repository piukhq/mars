//
//  LoginView.swift
//  binkapp
//
//  Created by Sean Williams on 21/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var formViewModel: FormViewModel
    private var viewModel: LoginViewViewModel
    
    init() {
        let datasource = FormDataSource(accessForm: .magicLink)
        self.formViewModel = FormViewModel(datasource: datasource, title: L10n.magicLinkTitle, description: L10n.magicLinkDescription)
        self.viewModel = LoginViewViewModel(datasource: datasource)
    }
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            BinkFormView(viewModel: formViewModel)
            if case .none = formViewModel.pickerType {
                BinkButtonsStackView(buttons: [viewModel.primaryButton])
            }
        })
    }
    
//    private func handlePrimaryButtonTap() {
//        viewModel.continueButtonTapped()
//    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
