//
//  FormFooterView.swift
//  binkapp
//
//  Created by Sean Williams on 20/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

final class FormFooterViewViewModel: ObservableObject {
    @Published var datasource: FormDataSource
    
    init(datasource: FormDataSource) {
        self.datasource = datasource
    }

    func toSecurityAndPrivacy() {
        let title: String = L10n.securityAndPrivacyTitle
        let description: String = L10n.securityAndPrivacyDescription
        let configuration = ReusableModalConfiguration(title: title, text: ReusableModalConfiguration.makeAttributedString(title: title, description: description))
        let viewController = ViewControllerFactory.makeSecurityAndPrivacyViewController(configuration: configuration)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func forgotPasswordTapped() {
        let viewController = ViewControllerFactory.makeForgottenPasswordViewController()
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
}

//struct FormFooterView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewCheckboxView()
//    }
//}

struct FormFooterView: View {
    @ObservedObject private var viewModel: FormFooterViewViewModel
    
    init(datasource: FormDataSource) {
        self.viewModel = FormFooterViewViewModel(datasource: datasource)
    }
    
    var body: some View {
        switch viewModel.datasource.formtype {
        case .authAndAdd:
            ForEach(Array(viewModel.datasource.checkboxes.enumerated()), id: \.offset) { _, checkbox in
                checkbox
            }
        case .addPaymentCard:
            Button {
                viewModel.toSecurityAndPrivacy()
            } label: {
                HStack {
                    Text(L10n.securityAndPrivacyTitle)
                        .underline()
                        .foregroundColor(Color(.blueAccent))
                        .font(.nunitoSemiBold(18))
                    Spacer()
                }
            }
            .padding(.horizontal, 5)
        case .login(let loginType):
            if !viewModel.datasource.checkboxes.isEmpty {
                VStack(spacing: -10) {
                    ForEach(Array(viewModel.datasource.checkboxes.enumerated()), id: \.offset) { _, checkbox in
                        checkbox
                    }
                }
            }
            
            HStack {
                if loginType == .emailPassword {
                    Button {
                        viewModel.forgotPasswordTapped()
                    } label: {
                        Text(L10n.loginForgotPassword)
                            .foregroundColor(Color(.blueAccent))
                            .underline()
                            .font(.nunitoSemiBold(18))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 5)
        }
    }
}
