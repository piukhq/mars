//
//  AuthAndAddView.swift
//  binkapp
//
//  Created by Sean Williams on 24/08/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct AuthAndAddView: View {
    @ObservedObject var formViewModel: FormViewModel
    @State var isLoading = false

    private let viewModel: AuthAndAddViewModel
    private let buttonViewModel: ButtonViewModel
    private var primaryButton: BinkButtonView {
        return BinkButtonView(viewModel: buttonViewModel, title: viewModel.buttonTitle, buttonTapped: handlePrimaryButtonTap, type: .gradient)
    }

    init(viewModel: AuthAndAddViewModel) {
        self.viewModel = viewModel
        let datasource = FormDataSource(authAdd: viewModel.getMembershipPlan(), formPurpose: viewModel.formPurpose, prefilledValues: viewModel.prefilledFormValues)
        buttonViewModel = ButtonViewModel(datasource: datasource)
        self.formViewModel = FormViewModel(datasource: datasource, title: viewModel.title, description: viewModel.getDescription(), membershipPlan: viewModel.getMembershipPlan())
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            BinkFormView(viewModel: formViewModel)
            if case .none = formViewModel.formInputType {
                BinkButtonsStackView(buttons: [primaryButton])
            }
        })
        .onReceive(formViewModel.datasource.$formPurpose) { output in
            if let formPurpose = output {
                viewModel.formPurpose = formPurpose
            }
        }
    }
    
    private func handlePrimaryButtonTap() {
        try? viewModel.addMembershipCard(with: formViewModel.datasource.fields, checkboxes: formViewModel.datasource.checkboxes, completion: {
            self.buttonViewModel.isLoading = false
        })
    }
}
