//
//  BinkFormView.swift
//  binkapp
//
//  Created by Sean Williams on 17/08/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Combine
import SwiftUI

struct BinkFormView: View {
    enum Constants {
        static let vStackInsets = EdgeInsets(top: 20, leading: 25, bottom: 150, trailing: 25)
    }
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: FormViewModel
    @ObservedObject private var themeManager = Current.themeManager
    @ObservedObject private var imageLoader = ImageLoader()
    @State var checkedState = false
    var plan: CD_MembershipPlan!
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            /// Temporary workaround to force background color beyond bottom safe area. Once iOS 13 has been dropped, replace with ignoringSafeAreas modifier
            Rectangle()
                .foregroundColor(Color(themeManager.color(for: .viewBackground)))
                .frame(height: 100, alignment: .center)
                .offset(y: 50.0)
            ///
            
            ScrollView {
                VStack(alignment: .center, spacing: 20.0) {
                    RemoteImage(image: imageLoader.image)
                        .onAppear {
                            imageLoader.retrieveImage(for: viewModel.membershipPlan, colorScheme: colorScheme)
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
                    
                    
                    VStack(alignment: .leading, spacing: 5, content: {
                        Text(viewModel.titleText ?? "")
                            .font(.custom(UIFont.headline.fontName, size: UIFont.headline.pointSize))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(viewModel.descriptionText ?? "")
                            .font(.custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
                            .fixedSize(horizontal: false, vertical: true)
                    })
                    
                    // Textfields
                    ForEach(viewModel.datasource.fields) { field in
                        if #available(iOS 14.0, *) {
                            BinkTextfieldView(field: field, didExit: $viewModel.textfieldDidExit)
                                .accessibilityIdentifier(field.title)
                                .keyboardType(field.fieldType.keyboardType())
                        } else {
                            BinkTextfieldView(field: field, didExit: $viewModel.textfieldDidExit)
                        }
                    }
                    
                    // Checkboxes
                    VStack(spacing: -10) {
                        ForEach(viewModel.datasource.checkboxes) { checkbox in
                            CheckboxSwiftUIVIew(checkbox: checkbox, checkedState: $checkedState)
                                .padding(.horizontal, 10)
                        }
                    }
                    .frame(height: 100)
                }
                .padding(Constants.vStackInsets)
            }
            .background(Color(themeManager.color(for: .viewBackground)))
            .padding(.bottom, viewModel.keyboardHeight)
            .onReceive(Publishers.keyboardHeight, perform: { self.viewModel.keyboardHeight = $0 })
        })
    }
}

struct BinkTextfieldView: View {
    @State var field: FormField
    @State private var isEditing = false
    @State var value: String = ""
    @State var showErrorState = false
    @Binding var fieldDidExit: Bool
    
    init(field: FormField, didExit: Binding<Bool>) {
        self.field = field
        _fieldDidExit = didExit
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
                                self.fieldDidExit = isEditing
                                
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
                if textfieldValidationFailed(value: $value) {
                    Text(field.validationErrorMessage ?? L10n.formFieldValidationError)
                        .font(.custom(UIFont.textFieldExplainer.fontName, size: UIFont.textFieldExplainer.pointSize))
                        .foregroundColor(Color(.errorRed))
                        .padding(.leading)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func textfieldValidationFailed(value: Binding<String>) -> Bool {
        field.updateValue(value.wrappedValue)
        guard showErrorState else { return false }
        return !field.isValid() && !value.wrappedValue.isEmpty
    }
    
    private func underlineColor(isEdting: Binding<Bool>) -> Color {
        var color: UIColor
        if isEditing {
            color = .activeBlue
            
            if textfieldValidationFailed(value: $value) {
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

let shouldChangeBlock: FormField.TextFieldShouldChange = { (_, _, _, _) in
    return false
}

let field1 = FormField(title: "Email", placeholder: "Enter your email bitch", validation: "", fieldType: .email, updated: { _, _ in }, shouldChange: shouldChangeBlock, fieldExited: { _ in })
let datasourceMock = FormDataSource(PaymentCardCreateModel(fullPan: nil, nameOnCard: nil, month: nil, year: nil))

struct BinkFormView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
//                Rectangle()
//                    .foregroundColor(Color(UIColor.grey10))
//                BinkFormView(viewModel: FormViewModel(datasource: datasourceMock, title: "Title text", description: "Im a description", membershipPlan: nil, colorScheme: ColorScheme.light))
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
