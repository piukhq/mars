//
//  FormViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 08/09/2021.
//  Copyright © 2021 Bink. All rights reserved.


import SwiftUI

final class FormViewModel: ObservableObject {
    @Published var datasource: FormDataSource
    @Published var brandImage: Image?
    @Published var textfieldDidExit = false
    @State var keyboardHeight: CGFloat = 0

    var titleText: String?
    var descriptionText: String?
    let membershipPlan: CD_MembershipPlan
    
    init(datasource: FormDataSource, title: String?, description: String?, membershipPlan: CD_MembershipPlan) {
        self.datasource = datasource
        self.titleText = title
        self.descriptionText = description
        self.membershipPlan = membershipPlan
//        configureBrandImage(colorScheme: colorScheme! )
    }
    
    var infoButtonText: String? {
        if let planName = membershipPlan.account?.planName {
            return "\(planName) info"
        }
        return nil
    }
    
    var shouldShowInfoButton: Bool {
        return infoButtonText != nil
    }
    
//    var shouldShowBrandImage: Bool {
//        return membershipPlan != nil
//    }
    
//    func configureBrandImage(colorScheme: ColorScheme) {
//        ImageService.getImage(forPathType: .membershipPlanIcon(plan: membershipPlan), traitCollection: nil, colorScheme: colorScheme) { uiImage in
//            if let uiImage = uiImage {
//                self.brandImage = Image(uiImage: uiImage)
//            }
//        }
//    }
//
    func infoButtonWasTapped() {
        let viewController = ViewControllerFactory.makeAboutMembershipPlanViewController(membershipPlan: membershipPlan)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
}
