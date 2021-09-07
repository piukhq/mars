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

    private let viewModel: AuthAndAddViewModel
    private let datasource: FormDataSource

    init(viewModel: AuthAndAddViewModel) {
        self.viewModel = viewModel
        datasource = FormDataSource(authAdd: viewModel.getMembershipPlan(), formPurpose: viewModel.formPurpose, prefilledValues: viewModel.prefilledFormValues)
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            BinkFormView(viewModel: FormViewModel(datasource: datasource, title: viewModel.title, description: viewModel.getDescription(), membershipPlan: viewModel.getMembershipPlan(), colorScheme: colorScheme))
            BinkButtonsStackView(buttons: [BinkGradientButtonSwiftUIView(title: viewModel.buttonTitle, enabled: datasource.fullFormIsValid)])
                .offset(y: BinkButtonsView.bottomSafePadding - BinkButtonsView.bottomPadding)
        })
    }
}

//struct AuthAndAddView_Previews: PreviewProvider {
//    static var previews: some View {
//        AuthAndAddView(viewModel: )
//    }
//}
