//
//  FormFooterView.swift
//  binkapp
//
//  Created by Sean Williams on 20/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

final class FormFooterViewViewModel: ObservableObject {
    @Published var datasource: FormDataSource {
        didSet {
            print("datasource update")
        }
    }
    private var privacyPolicy: NSMutableAttributedString?
    private var termsAndConditions: NSMutableAttributedString?
    
    @Published var checkboxStates: [Bool] = [] {
        didSet {
            print(checkboxStates)
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
    
    init(datasource: FormDataSource) {
        self.datasource = datasource
        
        datasource.checkboxes.forEach { checkBox in
            self.checkboxStates.append(checkBox.checkedState)
        }
    }
    
    var checkboxStackHeight: CGFloat {
        return datasource.checkboxes.count == 3 ? 150 : 100
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
        }
    }
}

struct FormFooterView: View {
    private var formViewModel: FormViewModel
    @ObservedObject private var model: FormFooterViewViewModel
    
    init(viewModel: FormViewModel) {
        self.formViewModel = viewModel
        self.model = FormFooterViewViewModel(datasource: formViewModel.datasource)
    }
    
    var body: some View {
        switch formViewModel.datasource.formtype {
        case .authAndAdd:
            // Checkboxes
            VStack(spacing: -10) {
                ForEach(Array(formViewModel.datasource.checkboxes.enumerated()), id: \.offset) { offset, checkbox in
                    CheckboxSwiftUIVIew(checkbox: checkbox, checkedState: $model.checkboxStates[offset], didTapOnURL: $model.didTapOnURL)
                       .padding(.horizontal, 10)
                }
            }
            .frame(height: model.checkboxStackHeight)
            .onAppear(perform: {
                DispatchQueue.global(qos: .userInitiated).async {
                    model.configureAttributedStrings()
                }
            })
        case .addPaymentCard:
            Button {
                
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
            
        case .login:
            Text("")
        }
    }
}

//struct FormFooterView_Previews: PreviewProvider {
//    static var previews: some View {
//        FormFooterView()
//    }
//}
