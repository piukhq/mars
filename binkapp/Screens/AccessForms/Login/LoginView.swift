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

    private var primaryButton: BinkGradientButtonSwiftUIView {
        return BinkGradientButtonSwiftUIView(datasource: formViewModel.datasource, isLoading: false, title: L10n.continueButtonTitle, buttonTapped: handlePrimaryButtonTap)
    }
    
    init() {
        self.formViewModel = FormViewModel(datasource: FormDataSource(accessForm: .magicLink), title: L10n.magicLinkTitle, description: L10n.magicLinkDescription)
    }
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            BinkFormView(viewModel: formViewModel)
            if case .none = formViewModel.pickerType {
                BinkButtonsStackView(buttons: [primaryButton])
            }
        })
    }
    
    private func handlePrimaryButtonTap() {

    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
