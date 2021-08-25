//
//  BinkFormView.swift
//  binkapp
//
//  Created by Sean Williams on 17/08/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Combine
import SwiftUI

let shouldChangeBlock: FormField.TextFieldShouldChange = { (_, _, _, _) in
    return false
}

let field1 = FormField(title: "Email", placeholder: "Enter your email bitch", validation: "", fieldType: .email, updated: { _, _ in }, shouldChange: shouldChangeBlock, fieldExited: { _ in })
let datasourceMock = FormDataSource(PaymentCardCreateModel(fullPan: nil, nameOnCard: nil, month: nil, year: nil))


final class FormViewModel: ObservableObject {
    @Published var datasource: FormDataSource
    @Published var brandImage: Image?
    @State var keyboardHeight: CGFloat = 0

    var titleText: String?
    var descriptionText: String?
    var membershipPlan: CD_MembershipPlan?
    
    init(datasource: FormDataSource, title: String?, description: String?, membershipPlan: CD_MembershipPlan?) {
        self.datasource = datasource
        self.titleText = title
        self.descriptionText = description
        self.membershipPlan = membershipPlan
        configureBrandImage()
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
    
    var shouldShowBrandImage: Bool {
        return membershipPlan != nil
    }
    
    func configureBrandImage() {
        guard let plan = membershipPlan else { return }
        ImageService.getImage(forPathType: .membershipPlanIcon(plan: plan), traitCollection: nil) { uiImage in
            if let uiImage = uiImage {
                self.brandImage = Image(uiImage: uiImage)
            }
        }
    }
}

struct BinkFormView: View {
    enum Constants {
        static let vStackInsets = EdgeInsets(top: 20, leading: 25, bottom: 150, trailing: 25)
    }
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: FormViewModel
    var plan: CD_MembershipPlan!

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20.0) {
//                if colorScheme == .dark {
//
//                }

                viewModel.brandImage?
                    .resizable()
                    .frame(width: 70, height: 70, alignment: .center)
                    .aspectRatio(contentMode: .fit)
                
                if viewModel.shouldShowInfoButton {
                    Button(action: {
                        // TODO: - Open info view
                    }, label: {
                        Text(viewModel.infoButtonText ?? "")
                            .font(.custom(UIFont.linkTextButtonNormal.fontName, size: UIFont.linkTextButtonNormal.pointSize))
                        Image(uiImage: Asset.iconsChevronRight.image.withRenderingMode(.alwaysTemplate))
                            .resizable()
                            .frame(width: 10, height: 10, alignment: .center)
                    })
                    .foregroundColor(Color(.blueAccent))
                }


                VStack(alignment: .leading, spacing: 5, content: {
                    Text(viewModel.titleText ?? "")
                        .font(.custom(UIFont.headline.fontName, size: UIFont.headline.pointSize))
                        .multilineTextAlignment(.leading)
                    Text(viewModel.descriptionText ?? "")
                        .font(.custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
                })
                
                ForEach(viewModel.datasource.fields) { field in
                    if #available(iOS 14.0, *) {
                        BinkTextfieldView(field: field)
                            .accessibilityIdentifier(field.title)
                            .keyboardType(field.fieldType.keyboardType())
                    } else {
                        BinkTextfieldView(field: field)
                    }
                }
            }
            .padding(Constants.vStackInsets)
        }
        .background(Color(UIColor.binkWhiteViewBackground))
        .padding(.bottom, viewModel.keyboardHeight)
        .onReceive(Publishers.keyboardHeight, perform: { self.viewModel.keyboardHeight = $0 })
    }
}

struct BinkTextfieldView: View {
    @State var field: FormField
    @State private var isEditing = false
    @State var value: String = ""
    @State var showErrorState = false
    
    init(field: FormField) {
        self.field = field
        UITextField.appearance().clearButtonMode = field.fieldCommonName == .barcode ? .always : .whileEditing
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .foregroundColor(.white)
                
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(field.title)
                            .font(.custom(UIFont.bodyTextSmall.fontName, size: UIFont.bodyTextSmall.pointSize))
                        
                        if field.fieldType.isSecureTextEntry {
                            SecureField(field.placeholder, text: $value) {
                                self.field.updateValue(value)
                                self.field.fieldWasExited()
                                self.isEditing = false
                            }
                            .onTapGesture {
                                isEditing = true
                            }
                        } else {
                            TextField(field.placeholder, text: $value, onEditingChanged: { isEditing in
                                self.isEditing = isEditing
                                self.field.updateValue(value)
                                
                                if isEditing {
//                                    self.datasource.formViewDidSelectField(self)
                                } else {
                                    self.field.fieldWasExited()
                                }
                                showErrorState = !field.isValid() && !value.isEmpty
                            }, onCommit: {
                                self.showErrorState = true
                            })
                            .font(.custom(UIFont.textFieldInput.fontName, size: UIFont.textFieldInput.pointSize))
                            .autocapitalization(field.fieldType.capitalization())
                            .coordinateSpace(name: "textfield")
                        }
                    }
                    
                    if field.isValid() && !isEditing {
                        Image(Asset.iconCheck.name)
                            .offset(x: -5, y: 11)
                    }
                    
                    if field.fieldCommonName == .cardNumber && !isEditing {
                        Button(action: {
//                            if field.fieldType == .paymentCardNumber {
//                                datasource.formViewDidReceivePaymentScannerButtonTap(self)
//                            } else {
//                                datasource.formViewDidReceiveLoyaltytScannerButtonTap(self)
//                            }
                        }) {
                            Image(Asset.scanIcon.name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25.0)
                        }
                        .offset(x: -5, y: 11)
                    }
                }
                .padding([.leading, .trailing], 15)
                
                Rectangle()
                    .fill(underlineColor(isEdting: $isEditing))
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 6, alignment: .top)
                    .clipped()
                    .offset(y: 34)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(width: nil, height: 70, alignment: .center)
            
            if field.fieldType.isSecureTextEntry {
                // TODO: - Validation point TextViews
            } else {
                if textfieldValidationPassed(value: $value) {
                    Text(field.validationErrorMessage ?? L10n.formFieldValidationError)
                        .font(.custom(UIFont.textFieldExplainer.fontName, size: UIFont.textFieldExplainer.pointSize))
                        .foregroundColor(Color(.errorRed))
                        .padding(.leading)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func textfieldValidationPassed(value: Binding<String>) -> Bool {
        field.updateValue(value.wrappedValue)
        guard showErrorState else { return false }
        return !field.isValid() && !value.wrappedValue.isEmpty
    }
    
    private func underlineColor(isEdting: Binding<Bool>) -> Color {
        var color: UIColor
        if isEditing {
            color = .activeBlue
            
            if textfieldValidationPassed(value: $value) {
                color = .errorRed
            }
        } else {
            color = field.isValid() ? .successGreen : .errorRed
        }
        
        if value.isEmpty && !isEditing {
            color = .clear
        }
        return Color(color)
    }
}


// MARK: - Previews

struct BinkFormView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
//                Rectangle()
//                    .foregroundColor(Color(UIColor.grey10))
                BinkFormView(viewModel: FormViewModel(datasource: datasourceMock, title: "Title text", description: "Im a description", membershipPlan: nil))
//                    .preferredColorScheme(.light)
            }
        }
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

//#if canImport(UIKit)
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}
//#endif
