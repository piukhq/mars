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

    private let viewModel: AuthAndAddViewModel
    private let datasource: FormDataSource
    
    private var primaryButton: BinkGradientButtonSwiftUIView {
        return BinkGradientButtonSwiftUIView(enabled: checkFormValidity(didExit: $formViewModel.textfieldDidExit, checkedState: $formViewModel.checkedState), isLoading: false, title: viewModel.buttonTitle, buttonTapped: handlePrimaryButtonTap)
    }

    init(viewModel: AuthAndAddViewModel) {
        self.viewModel = viewModel
        self.datasource = FormDataSource(authAdd: viewModel.getMembershipPlan(), formPurpose: viewModel.formPurpose, prefilledValues: viewModel.prefilledFormValues)
        self.formViewModel = FormViewModel(datasource: datasource, title: viewModel.title, description: viewModel.getDescription(), membershipPlan: viewModel.getMembershipPlan())
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            BinkFormView(viewModel: formViewModel)
            BinkButtonsStackView(buttons: [primaryButton])
                .offset(y: BinkButtonsView.bottomSafePadding - BinkButtonsView.bottomPadding)
        })
        .onAppear(perform: {
            DispatchQueue.global(qos: .userInitiated).async {
                formViewModel.configureAttributedStrings()
            }
        })
    }
    
    private func checkFormValidity(didExit: Binding<Bool>, checkedState: Binding<Bool>) -> Bool {
        return datasource.fullFormIsValid
    }
    
    private func handlePrimaryButtonTap() {
        try? viewModel.addMembershipCard(with: datasource.fields, checkboxes: datasource.checkboxes, completion: {
            primaryButton.isLoading = false
        })
    }
}

//struct AuthAndAddView_Previews: PreviewProvider {
//    static var previews: some View {
//        AuthAndAddView(viewModel: )
//    }
//}
