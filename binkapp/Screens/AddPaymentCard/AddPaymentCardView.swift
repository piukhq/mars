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
    
    private let viewModel: AddPaymentCardViewModel
    private var primaryButton: BinkGradientButtonSwiftUIView {
        return BinkGradientButtonSwiftUIView(datasource: formViewModel.datasource, isLoading: false, title: L10n.addButtonTitle, buttonTapped: handlePrimaryButtonTap, type: .gradient)
    }
    
    init(viewModel: AddPaymentCardViewModel) {
        self.viewModel = viewModel
        self.formViewModel = FormViewModel(datasource: viewModel.formDataSource, title: L10n.addPaymentCardTitle, description: L10n.addPaymentCardDescription, addPaymentCardViewModel: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            BinkFormView(viewModel: formViewModel)
            if case .none = formViewModel.pickerType {
                BinkButtonsStackView(buttons: [primaryButton])
            }
        })
    }
    
    private func handlePrimaryButtonTap() {
        if viewModel.shouldDisplayTermsAndConditions {
            viewModel.toPaymentTermsAndConditions(acceptAction: {
                Current.navigate.close {
                    self.viewModel.addPaymentCard {
                        primaryButton.isLoading = false
                    }
                }
            }, declineAction: {
                Current.navigate.close()
            })
        } else {
            viewModel.addPaymentCard {
                primaryButton.isLoading = false
            }
        }
    }
}

//struct AddPaymentCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddPaymentCardView(formViewModel: FormViewModel(datasource: FormDataSource(PaymentCardCreateModel(fullPan: "", nameOnCard: "Sean", month: 1, year: 12)), title: <#T##String?#>, description: <#T##String?#>, membershipPlan: <#T##CD_MembershipPlan#>), viewModel: <#AddPaymentCardViewModel#>)
//    }
//}
