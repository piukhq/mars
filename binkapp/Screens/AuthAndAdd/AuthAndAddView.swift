//
//  AuthAndAddView.swift
//  binkapp
//
//  Created by Sean Williams on 24/08/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

//let datasourceMock = AuthAndAddViewModel(membershipPlan: <#T##CD_MembershipPlan#>, formPurpose: .add)


struct AuthAndAddView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var primaryButtonTapped = false
    
    private var primaryButton: BinkButton
    
//    private lazy var primaryButton: BinkButtonView = {
//        let binkButton = BinkButton(type: .gradient, title: viewModel.buttonTitle, enabled: datasource.fullFormIsValid, action: {})
//        return BinkButtonView(button: binkButton, wasTapped: $primaryButtonTapped)
//    }()

    private let viewModel: AuthAndAddViewModel
    private let datasource: FormDataSource

    init(viewModel: AuthAndAddViewModel) {
        self.viewModel = viewModel
        datasource = FormDataSource(authAdd: viewModel.getMembershipPlan(), formPurpose: viewModel.formPurpose, prefilledValues: viewModel.prefilledFormValues)
        self.primaryButton = BinkButton(type: .gradient, title: viewModel.buttonTitle, enabled: datasource.fullFormIsValid, action: {})
    }
    
    var body: some View {
//        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            BinkFormView(viewModel: FormViewModel(datasource: datasource, title: viewModel.title, description: viewModel.getDescription(), membershipPlan: viewModel.getMembershipPlan(), colorScheme: colorScheme, footerButtons: [primaryButton]))
            
//            BinkButtonsSwiftUIView(buttons: [primaryButton])
//                .frame(width: 200, alignment: .bottom)
//        })
    }
    
    private mutating func handlePrimaryButtonTap() {
//        primaryButton.toggleLoading(isLoading: true)
        try? viewModel.addMembershipCard(with: datasource.fields, checkboxes: datasource.checkboxes, completion: {
//            self.primaryButton.toggleLoading(isLoading: false)
        })
    }
}

//struct AuthAndAddView_Previews: PreviewProvider {
//    static var previews: some View {
//        AuthAndAddView(viewModel: )
//    }
//}
