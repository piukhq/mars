//
//  FormHeaderView.swift
//  binkapp
//
//  Created by Sean Williams on 15/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

final class FormHeaderViewViewModel: ObservableObject {
    @Published var brandImage: Image?
    @State var paymentCard: PaymentCardCreateModel?
    var membershipPlan: CD_MembershipPlan?
    var formType: FormType
    
    init(formType: FormType, membershipPlan: CD_MembershipPlan?, paymentCard: Binding<PaymentCardCreateModel?>) {
        self.formType = formType
        self.membershipPlan = membershipPlan
        _paymentCard = State(initialValue: paymentCard.wrappedValue)
    }

    var infoButtonText: String? {
        if let planName = membershipPlan?.account?.planName {
            return L10n.aboutCustomTitle(planName)
        }
        return nil
    }
    
    var shouldShowInfoButton: Bool {
        return infoButtonText != nil
    }
    
    func infoButtonWasTapped() {
        guard let membershipPlan = membershipPlan else { return }
        let viewController = ViewControllerFactory.makeAboutMembershipPlanViewController(membershipPlan: membershipPlan)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func retrieveImage(colorScheme: ColorScheme) {
        guard let membershipPlan = membershipPlan else { return }
        ImageService.getImage(forPathType: .membershipPlanIcon(plan: membershipPlan), traitCollection: nil, colorScheme: colorScheme) { uiImage in
            guard let uiImage = uiImage else { return }
            self.brandImage = Image(uiImage: uiImage)
        }
    }
}

struct FormHeaderView: View {
    @ObservedObject var viewModel: FormHeaderViewViewModel
    @Environment(\.colorScheme) var colorScheme
    
    init(formType: FormType, membershipPlan: CD_MembershipPlan?, paymentCard: Binding<PaymentCardCreateModel?>) {
        viewModel = FormHeaderViewViewModel(formType: formType, membershipPlan: membershipPlan, paymentCard: paymentCard)
        viewModel.retrieveImage(colorScheme: colorScheme)
    }

    var body: some View {
        if case .authAndAdd = viewModel.formType {
            RemoteImage(image: viewModel.brandImage)
                .frame(width: 70, height: 70, alignment: .center)
                .aspectRatio(contentMode: .fit)
            if viewModel.shouldShowInfoButton {
                Button(action: {
                    viewModel.infoButtonWasTapped()
                }, label: {
                    Text(viewModel.infoButtonText ?? "")
                        .font(.custom(UIFont.linkTextButtonNormal.fontName, size: UIFont.linkTextButtonNormal.pointSize))
                        .underline()
                })
                .foregroundColor(Color(.blueAccent))
            }
        } else if case .addPaymentCard = viewModel.formType {
            PaymentCardCellSwiftUIView(paymentCard: $viewModel.paymentCard)
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .padding(.bottom, 20)
        }
    }
}
