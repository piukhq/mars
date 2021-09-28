//
//  CheckboxSwiftUIViewViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 28/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

class CheckboxSwiftUIViewViewModel: ObservableObject {
    private var privacyPolicy: NSMutableAttributedString?
    private var termsAndConditions: NSMutableAttributedString?
    var membershipPlan: CD_MembershipPlan?
    var checkedState = false
    
    @Published var url: URL? {
        didSet {
            if let url = url {
                presentPlanDocumentsModal(withUrl: url)
            }
        }
    }

    init(membershipPlan: CD_MembershipPlan?) {
        self.membershipPlan = membershipPlan
        DispatchQueue.global(qos: .userInitiated).async {
            self.configureAttributedStrings()
        }
    }

    func configureAttributedStrings() {
        for document in (membershipPlan?.account?.planDocuments) ?? [] {
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
        } else {
            let viewController = ViewControllerFactory.makeWebViewController(urlString: url.absoluteString)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
}
