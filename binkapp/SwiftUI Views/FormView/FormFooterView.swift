//
//  FormFooterView.swift
//  binkapp
//
//  Created by Sean Williams on 20/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

final class FormFooterViewViewModel: ObservableObject {
    @Published var datasource: FormDataSource
    @Published var checkboxStates: [Bool] = [] {
        didSet {
            datasource.checkFormValidity()
        }
    }
    @Published var didTapOnURL: URL? {
        didSet {
            if let url = didTapOnURL {
                presentPlanDocumentsModal(withUrl: url)
            }
        }
    }
    private var privacyPolicy: NSMutableAttributedString?
    private var termsAndConditions: NSMutableAttributedString?
    
    init(datasource: FormDataSource) {
        self.datasource = datasource
        
        datasource.checkboxes.forEach { checkBox in
            self.checkboxStates.append(checkBox.checkedState)
        }
    }
    
    var checkboxStackHeight: CGFloat {
        switch datasource.formtype {
        case .authAndAdd, .addPaymentCard:
            return datasource.checkboxes.count == 3 ? 420 : 100
        case .login(let accessForm):
            switch accessForm {
            case .termsAndConditions:
                return 230
            default:
                return 100
            }
        }
    }
    
    func configureAttributedStrings() {
        for document in (datasource.membershipPlan?.account?.planDocuments) ?? [] {
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
            let modalConfig = ReusableModalConfiguration(text: text, membershipPlan: datasource.membershipPlan)
            let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: modalConfig)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        } else {
            let viewController = ViewControllerFactory.makeWebViewController(urlString: url.absoluteString)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
    
    func toSecurityAndPrivacy() {
        let title: String = L10n.securityAndPrivacyTitle
        let description: String = L10n.securityAndPrivacyDescription
        let configuration = ReusableModalConfiguration(title: title, text: ReusableModalConfiguration.makeAttributedString(title: title, description: description))
        let viewController = ViewControllerFactory.makeSecurityAndPrivacyViewController(configuration: configuration)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func forgotPasswordTapped() {
        let viewController = ViewControllerFactory.makeForgottenPasswordViewController()
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
}

struct FormFooterView_Previews: PreviewProvider {
    static var previews: some View {
        NewCheckboxView()
    }
}

struct NewCheckboxView: View {
    @State var checkboxText = ""
    
    var body: some View {
        HStack {
            VStack {
                Button(action: {
                    print("it works!")
                }, label: {
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(width: 22, height: 22)
                })
            }
            
            Text(checkboxText)
            Spacer()
        }
    }
}

struct FormFooterView: View {
    @ObservedObject private var viewModel: FormFooterViewViewModel
    
    init(datasource: FormDataSource) {
        self.viewModel = FormFooterViewViewModel(datasource: datasource)
    }
    
    var body: some View {
        switch viewModel.datasource.formtype {
        case .authAndAdd:
            VStack() {
                NewCheckboxView(checkboxText: "Check this box to receive money off promotion, special offers and information on latest deals and more from Iceland by email")
                NewCheckboxView(checkboxText: "I accept the retailer terms and conditions")
                NewCheckboxView(checkboxText: "Please read the Iceland Privacy Policy")
//                ForEach(Array(viewModel.datasource.checkboxes.enumerated()), id: \.offset) { offset, checkbox in
////                    CheckboxSwiftUIVIew(checkbox: checkbox, checkedState: $viewModel.checkboxStates[offset], didTapOnURL: $viewModel.didTapOnURL)
////                        .padding(.horizontal, 5)
////                        .frame(minHeight: 30, idealHeight: 100, maxHeight: .infinity)
//                }
            }
//            .frame(height: viewModel.checkboxStackHeight)
            .onAppear(perform: {
                DispatchQueue.global(qos: .userInitiated).async {
                    viewModel.configureAttributedStrings()
                }
            })
        case .addPaymentCard:
            Button {
                viewModel.toSecurityAndPrivacy()
            } label: {
                HStack {
                    Text(L10n.securityAndPrivacyTitle)
                        .underline()
                        .foregroundColor(Color(.blueAccent))
                        .font(.nunitoSemiBold(18))
                    Spacer()
                }
            }
            .padding(.horizontal, 5)
        case .login(let loginType):
            if !viewModel.datasource.checkboxes.isEmpty {
                VStack(spacing: -10) {
                    ForEach(Array(viewModel.datasource.checkboxes.enumerated()), id: \.offset) { offset, checkbox in
                        CheckboxSwiftUIVIew(checkbox: checkbox, checkedState: $viewModel.checkboxStates[offset], didTapOnURL: $viewModel.didTapOnURL)
                            .padding(.horizontal, 5)
                    }
                }
                .frame(height: viewModel.checkboxStackHeight)
            }

            HStack {
                if loginType == .emailPassword {
                    Button {
                        viewModel.forgotPasswordTapped()
                    } label: {
                        Text(L10n.loginForgotPassword)
                            .foregroundColor(Color(.blueAccent))
                            .underline()
                            .font(.nunitoSemiBold(18))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 5)
        }
    }
}
