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
        return BinkButtonView(viewModel: viewModel.buttonViewModel, buttonTapped: viewModel.continueButtonTapped, type: .gradient)
    }
    
    @State private var formViewModel: FormViewModel
    private let viewModel: TermsAndConditionsViewModel
    
    init(requestType: LoginRequestType) {
        viewModel = TermsAndConditionsViewModel(requestType: requestType)
        formViewModel = FormViewModel(datasource: viewModel.datasource, title: L10n.socialTandcsTitle, description: L10n.socialTandcsSubtitle)
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

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView(requestType: .apple(SignInWithAppleRequest(authorizationCode: "")))
    }
}
