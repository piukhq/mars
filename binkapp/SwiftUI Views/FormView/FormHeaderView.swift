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
    
    init(membershipPlan: CD_MembershipPlan?) {
        self.membershipPlan = membershipPlan
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
//    @ObservedObject var viewModel: FormViewModel
    @ObservedObject var viewModel: FormHeaderViewViewModel
    @ObservedObject private var imageLoader = ImageLoader()
    @Environment(\.colorScheme) var colorScheme
    
    init(membershipPlan: CD_MembershipPlan?) {
        viewModel = FormHeaderViewViewModel(membershipPlan: membershipPlan)
    }

    var body: some View {
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
    }
}

//struct FormHeaderView_Previews: PreviewProvider {
//    static var previews: some View {
//        FormHeaderView()
//    }
//}
