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
    var membershipPlan: CD_MembershipPlan?
    var paymentCard: PaymentCardCreateModel?
    var formType: FormType
    
    init(formType: FormType, membershipPlan: CD_MembershipPlan?, paymentCard: PaymentCardCreateModel?) {
        self.formType = formType
        self.membershipPlan = membershipPlan
        self.paymentCard = paymentCard
    }

    var infoButtonText: String? {
        if let planName = membershipPlan?.account?.planName {
            return "\(planName) info"
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
}

struct FormHeaderView: View {
    @ObservedObject var viewModel: FormHeaderViewViewModel
    @ObservedObject private var imageLoader = ImageLoader()
    @Environment(\.colorScheme) var colorScheme
    
    init(formType: FormType, membershipPlan: CD_MembershipPlan?, paymentCard: PaymentCardCreateModel?) {
        viewModel = FormHeaderViewViewModel(formType: formType, membershipPlan: membershipPlan, paymentCard: paymentCard)
    }

    var body: some View {
        switch viewModel.formType {
        case .authAndAdd:
            RemoteImage(image: viewModel.brandImage ?? imageLoader.image)
                .onAppear {
                    if let membershipPlan = viewModel.membershipPlan {
                        imageLoader.retrieveImage(for: membershipPlan, colorScheme: colorScheme)
                        viewModel.brandImage = imageLoader.image
                    }
                }
                .frame(width: 70, height: 70, alignment: .center)
                .aspectRatio(contentMode: .fit)
            
            if viewModel.shouldShowInfoButton {
                Button(action: {
                    viewModel.infoButtonWasTapped()
                }, label: {
                    Text(viewModel.infoButtonText ?? "")
                        .font(.custom(UIFont.linkTextButtonNormal.fontName, size: UIFont.linkTextButtonNormal.pointSize))
                    Image(uiImage: Asset.iconsChevronRight.image.withRenderingMode(.alwaysTemplate))
                        .resizable()
                        .frame(width: 10, height: 10, alignment: .center)
                })
                .foregroundColor(Color(.blueAccent))
            }
        case .addPaymentCard:
            PaymentCardCellSwiftUIView(paymentCard: viewModel.paymentCard)
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .padding(.bottom, 20)
        case .login:
            Text("Sean")
        }
    }
}

//struct FormHeaderView_Previews: PreviewProvider {
//    static var previews: some View {
//        FormHeaderView()
//    }
//}
