//
//  AuthAndAddView.swift
//  binkapp
//
//  Created by Sean Williams on 24/08/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct AuthAndAddView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var formViewModel: FormViewModel

    private let viewModel: AuthAndAddViewModel
    private let datasource: FormDataSource

    init(viewModel: AuthAndAddViewModel) {
        self.viewModel = viewModel
        self.datasource = FormDataSource(authAdd: viewModel.getMembershipPlan(), formPurpose: viewModel.formPurpose, prefilledValues: viewModel.prefilledFormValues)
        self.formViewModel = FormViewModel(datasource: datasource, title: viewModel.title, description: viewModel.getDescription(), membershipPlan: viewModel.getMembershipPlan())
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            BinkFormView(viewModel: formViewModel)
            BinkButtonsStackView(buttons: [BinkGradientButtonSwiftUIView(enabled: checkFormValidity(didExit: $formViewModel.textfieldDidExit), title: viewModel.buttonTitle)])
                .offset(y: BinkButtonsView.bottomSafePadding - BinkButtonsView.bottomPadding)
        })
    }
    
    func checkFormValidity(didExit: Binding<Bool>) -> Bool {
        return datasource.fullFormIsValid
    }
}

//struct AuthAndAddView_Previews: PreviewProvider {
//    static var previews: some View {
//        AuthAndAddView(viewModel: )
//    }
//}
