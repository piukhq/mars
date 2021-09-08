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
    @Published var didTapOnURL: URL? {
        didSet {
            if let url = didTapOnURL {
                presentPlanDocumentsModal(withUrl: url)
            }
        }
    }
    @State var keyboardHeight: CGFloat = 0

    var titleText: String?
    var descriptionText: String?
    let membershipPlan: CD_MembershipPlan
    private var privacyPolicy: NSMutableAttributedString?
    private var termsAndConditions: NSMutableAttributedString?
    
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
    
    func configureAttributedStrings() {
        for document in (membershipPlan.account?.planDocuments) ?? [] {
            let planDocument = document as? CD_PlanDocument
            if planDocument?.name?.contains("policy") == true {
                if let urlString = planDocument?.url, let url = URL(string: urlString) {
                    privacyPolicy = HTMLParsingUtil.makeAttributedStringFromHTML(url: url)
                }
            }
            
            if planDocument?.name?.contains("conditions") == true {
                if let urlString = planDocument?.url, let url = URL(string: urlString) {
                    termsAndConditions = HTMLParsingUtil.makeAttributedStringFromHTML(url: url)
                }
            }
        }
    }
    
    func presentPlanDocumentsModal(withUrl url: URL) {
        if let text = url.absoluteString.contains("pp") ? privacyPolicy : termsAndConditions {
            let modalConfig = ReusableModalConfiguration(text: text, membershipPlan: membershipPlan)
            let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: modalConfig)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
}