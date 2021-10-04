//
//  AddPaymentCardView.swift
//  binkapp
//
//  Created by Sean Williams on 15/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct AddPaymentCardView: View {
    @ObservedObject var formViewModel: FormViewModel
    private var viewModel: AddPaymentCardViewModel

    init(viewModel: AddPaymentCardViewModel) {
        self.viewModel = viewModel
        self.formViewModel = FormViewModel(datasource: viewModel.datasource, title: L10n.addPaymentCardTitle, description: L10n.addPaymentCardDescription, addPaymentCardViewModel: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            BinkFormView(viewModel: formViewModel)
            if case .none = formViewModel.formInputType {
                BinkButtonsStackView(buttons: [viewModel.primaryButton])
            }
        })
    }
}
