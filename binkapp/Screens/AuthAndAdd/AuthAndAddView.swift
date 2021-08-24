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
    private let viewModel: AuthAndAddViewModel
    private let datasource: FormDataSource

    init(viewModel: AuthAndAddViewModel) {
        self.viewModel = viewModel
        datasource = FormDataSource(authAdd: viewModel.getMembershipPlan(), formPurpose: viewModel.formPurpose, prefilledValues: viewModel.prefilledFormValues)
    }
    
    var body: some View {
        BinkFormView(viewModel: FormViewModel(datasource: datasource, descriptionText: viewModel.getDescription()))
    }
}

//struct AuthAndAddView_Previews: PreviewProvider {
//    static var previews: some View {
//        AuthAndAddView(viewModel: )
//    }
//}
