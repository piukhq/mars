//
//  CheckboxSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 24/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

class CheckboxSwiftUIViewViewModel {
    private var privacyPolicy: NSMutableAttributedString?
    private var termsAndConditions: NSMutableAttributedString?
    var membershipPlan: CD_MembershipPlan?
    
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

struct CheckboxSwiftUIView: View {
    typealias CheckValidity = () -> Void

    @State var checkboxText: String
    @State var checkedState = false
    var viewModel: CheckboxSwiftUIViewViewModel
    var hideCheckbox: Bool
    var columnKind: FormField.ColumnKind?
    var optional: Bool
    var columnName: String?
    var url: URL?
    var checkValidity: CheckValidity
    
    var value: String {
        return checkedState ? "1" : "0"
    }
    
    init (text: String, columnName: String?, columnKind: FormField.ColumnKind?, url: URL? = nil, optional: Bool = false, hideCheckbox: Bool = false, membershipPlan: CD_MembershipPlan? = nil, checkValidity: @escaping CheckValidity) {
        self._checkboxText = State(initialValue: text)
        self.columnName = columnName
        self.columnKind = columnKind
        self.url = url
        self.optional = optional
        self.hideCheckbox = hideCheckbox
        self.viewModel = CheckboxSwiftUIViewViewModel(membershipPlan: membershipPlan)
        self.checkValidity = checkValidity
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if !hideCheckbox {
                VStack {
                    Button(action: {
                        checkedState.toggle()
                        checkValidity()
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(checkedState ? Color.black : Color.gray.opacity(0.4))
                                .frame(width: 22, height: 22)
                            
                            if checkedState {
                                Image(Asset.checkmark.name)
                                    .resizable()
                                    .frame(width: 15, height: 15, alignment: .center)
                                    .foregroundColor(.white)
                            } else {
                                RoundedRectangle(cornerRadius: 2.7, style: .continuous)
                                    .fill(Color.white)
                                    .frame(width: 18, height: 18)
                            }
                        }
                    })
                }
            }
            HStack(spacing: 4) {
                Text(checkboxText)
                    .foregroundColor(Color(Current.themeManager.color(for: .text)))
                    .font(.nunitoLight(14))
                
                if let columnName = columnName {
                    Button {
                        if let url = url {
                            viewModel.presentPlanDocumentsModal(withUrl: url)
                        }
                    } label: {
                        Text(columnName)
                            .font(.nunitoLight(14))
                            .foregroundColor(Color(.binkGradientBlueLeft))
                            .underline()
                    }
                }
            }
            Spacer()
        }
    }
}

struct CheckboxSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CheckboxSwiftUIView(text: "Check this box to receive money off promotion, special offers and information on latest deals and more from Iceland by email", columnName: nil, columnKind: .planDocument, url: URL(string: ""), optional: false, hideCheckbox: false, checkValidity: {})
            CheckboxSwiftUIView(text: "I accept the", columnName: "Retailer terms and conditions", columnKind: .planDocument, url: URL(string: ""), optional: false, hideCheckbox: false, checkValidity: {})
            CheckboxSwiftUIView(text: "I accept the", columnName: "Iceland privacy policy", columnKind: .planDocument, url: URL(string: ""), optional: false, hideCheckbox: true, checkValidity: {})
        }
    }
}
