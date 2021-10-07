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
    @ObservedObject private var viewModel: AuthAndAddViewModel
    @State var isLoading = false

    private let buttonViewModel: ButtonViewModel
    private var primaryButton: BinkButtonView {
        return BinkButtonView(viewModel: buttonViewModel, title: viewModel.buttonTitle, buttonTapped: handlePrimaryButtonTap, type: .gradient)
    }

    init(viewModel: AuthAndAddViewModel) {
        self.viewModel = viewModel
        self.buttonViewModel = ButtonViewModel(datasource: viewModel.dataSource)
        self.formViewModel = FormViewModel(datasource: viewModel.dataSource, title: viewModel.title, description: viewModel.getDescription(), membershipPlan: viewModel.getMembershipPlan())
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            FormView(viewModel: formViewModel)
            if case .none = formViewModel.formInputType {
                BinkButtonsStackView(buttons: [primaryButton])
            }
        })
        .onReceive(formViewModel.datasource.$formPurpose) { output in
            if let formPurpose = output {
                viewModel.formPurpose = formPurpose
            }
        }
        .onReceive(formViewModel.$textFieldClearButtonTapped) { output in
            guard output != nil else { return }
            viewModel.refreshFormDataSource()
        }
        .onReceive(viewModel.$dataSourcePublisher) { refreshedDataSource in
            guard let refreshedDataSource = refreshedDataSource else { return }
            formViewModel.datasource = refreshedDataSource
        }
    }
    
    private func handlePrimaryButtonTap() {
        try? viewModel.addMembershipCard(with: formViewModel.datasource.fields, checkboxes: formViewModel.datasource.checkboxes, completion: {
            self.buttonViewModel.isLoading = false
        })
    }
}
