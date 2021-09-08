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
    @Published var checkedState = false
    @State var keyboardHeight: CGFloat = 0

    var titleText: String?
    var descriptionText: String?
    let membershipPlan: CD_MembershipPlan
    
    init(datasource: FormDataSource, title: String?, description: String?, membershipPlan: CD_MembershipPlan) {
        self.datasource = datasource
        self.titleText = title
        self.descriptionText = description
        self.membershipPlan = membershipPlan
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

    func infoButtonWasTapped() {
        let viewController = ViewControllerFactory.makeAboutMembershipPlanViewController(membershipPlan: membershipPlan)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
}
