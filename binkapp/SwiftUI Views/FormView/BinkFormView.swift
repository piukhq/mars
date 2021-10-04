//
//  BinkFormView.swift
//  binkapp
//
//  Created by Sean Williams on 17/08/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Combine
import SwiftUI

enum FormViewConstants {
    static let vStackInsets = EdgeInsets(top: 20, leading: 25, bottom: 150, trailing: 25)
    static let inputToolbarHeight: CGFloat = 44
    static let multipleChoicePickerHeight: CGFloat = 200
    static let graphicalDatePickerHeight: CGFloat = 400
    static let datePickerHeight: CGFloat = 230
}

struct BinkFormView: View {
    @ObservedObject var viewModel: FormViewModel
    @State var pickerOneSelection = ""
    @State var pickerTwoSelection = ""
    
    var hyperlinkAttrString: NSAttributedString {
        return NSAttributedString(
            string: L10n.securityAndPrivacyTitle,
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.linkUnderlined, .foregroundColor: UIColor.blueAccent]
        )
    }

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
            ScrollView {
                VStack(alignment: .center, spacing: 20.0) {
                    FormHeaderView(formType: viewModel.datasource.formtype, membershipPlan: viewModel.membershipPlan, paymentCard: $viewModel.paymentCard)
                    
                    VStack(alignment: .leading, spacing: 5, content: {
                        Text(viewModel.titleText ?? "")
                            .font(.custom(UIFont.headline.fontName, size: UIFont.headline.pointSize))
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color(Current.themeManager.color(for: .text)))
                        
                        Text(viewModel.descriptionText ?? "")
                            .font(.custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color(Current.themeManager.color(for: .text)))
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 5)
                    
                    AttributedTextView(viewModel: viewModel)
                    
                    // Textfields
                    ForEach(viewModel.datasource.fields) { field in
                        if #available(iOS 14.0, *) {
                            BinkTextfieldView(field: field, viewModel: viewModel)
                                .accessibilityIdentifier(field.title)
                                .keyboardType(field.fieldType.keyboardType())
                        } else {
                            BinkTextfieldView(field: field, viewModel: viewModel)
                        }
                    }
                    
                    FormFooterView(datasource: viewModel.datasource)
                }
                .padding(FormViewConstants.vStackInsets)
            }
//            .background(Color(Current.themeManager.color(for: .viewBackground)))
            .edgesIgnoringSafeArea(.bottom)
//            .padding(.bottom, viewModel.keyboardHeight)
            .offset(y: -viewModel.keyboardHeight).animation(.linear(duration: 0.35))
            .onReceive(Publishers.keyboardHeight, perform: {
                if $0 == 0.0 {
                    self.viewModel.keyboardHeight = $0
                } else {
                    self.viewModel.keyboardHeight = $0 - ($0 - FormViewConstants.inputToolbarHeight)
                }
            })
//            .onReceive(Publishers.keyboardWillShow) { keyboardWillShow in
//                if keyboardWillShow {
//                    viewModel.pickerType = .keyboard
//                }
//            }
            
            // Keyboard Toolbar
            if viewModel.shouldShowTextfieldToolbar {
                VStack {
                    Spacer()
                    //                    VStack {
                    InputToolbarView {
//                        viewModel.showTextFieldToolbar = false
                        viewModel.formInputType = .none
                        viewModel.datasource.checkFormValidity()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .animation(.easeInOut(duration: 0.35))
                    //                        .offset(y: viewModel.keyboardHeight).animation(.easeInOut)
                    //                        .onReceive(Publishers.keyboardHeight, perform: { self.viewModel.keyboardHeight = $0 })
                    //                    }
                }
            }
            
            if case .date = viewModel.formInputType {
                if #available(iOS 14.0, *) {
                    VStack(spacing: 0) {
                        InputToolbarView(buttonAction: { viewModel.formInputType = .none })
                        
                        DatePicker("", selection: $viewModel.date ?? Date(), displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .frame(maxHeight: FormViewConstants.graphicalDatePickerHeight)
                            .background(Color(Current.themeManager.color(for: .viewBackground)))
                            .accentColor(Color(.blueAccent))
                    }
                    .offset(y: UIApplication.bottomSafeArea)
                } else {
                    VStack(spacing: 0) {
                        InputToolbarView(buttonAction: { viewModel.formInputType = .none })
                        
                        DatePicker("", selection: $viewModel.date ?? Date(), displayedComponents: .date)
                            .frame(width: UIScreen.main.bounds.width, height: FormViewConstants.datePickerHeight, alignment: .center)
                            .background(Color(Current.themeManager.color(for: .viewBackground)))
                            .accentColor(Color(.blueAccent))
                            .labelsHidden()
                            .edgesIgnoringSafeArea(.bottom)
                    }
                    .offset(y: UIApplication.bottomSafeArea)
                }
            } else if case .choice(let data) = viewModel.formInputType {
                VStack(spacing: 0) {
                    InputToolbarView(buttonAction: { viewModel.formInputType = .none })
                    
                    let formData = data.map { $0.title }
                    Picker("", selection: $pickerOneSelection.onChange({ _ in
                        viewModel.formatPickerData(pickerOne: pickerOneSelection, pickerTwo: pickerTwoSelection)
                    })) {
                        ForEach(formData, id: \.self) {
                            Text($0)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width, height: FormViewConstants.multipleChoicePickerHeight, alignment: .center)
                    .background(Color(Current.themeManager.color(for: .viewBackground)))
                    .labelsHidden()
                    //                    .offset(y: UIApplication.bottomSafeArea)
                    
                    //                    Spacer()
                    //                        .frame(height: UIApplication.bottomSafeArea)
                }
                .offset(y: UIApplication.bottomSafeArea)
                .background(Color.clear)
            } else if case .expiry(let months, let years) = viewModel.formInputType {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        Spacer()
                        InputToolbarView(buttonAction: { viewModel.formInputType = .none })
                        
                        HStack(spacing: 0) {
                            let monthsMapped = months.map { $0.title }
                            Picker("Expiry date", selection: $pickerOneSelection.onChange({ _ in
                                viewModel.formatPickerData(pickerOne: pickerOneSelection, pickerTwo: pickerTwoSelection)
                            })) {
                                ForEach(monthsMapped, id: \.self) {
                                    Text($0)
                                }
                            }
                            .background(Color(Current.themeManager.color(for: .viewBackground)))
                            .frame(width: geometry.size.width / 2)
                            .clipped()
                            
                            let yearsMapped = years.map { $0.title }
                            Picker("Expiry date", selection: $pickerTwoSelection.onChange({ _ in
                                viewModel.formatPickerData(pickerOne: pickerOneSelection, pickerTwo: pickerTwoSelection)
                            })) {
                                ForEach(yearsMapped, id: \.self) {
                                    Text($0)
                                }
                            }
                            .background(Color(Current.themeManager.color(for: .viewBackground)))
                            .frame(width: geometry.size.width / 2)
                            .clipped()
                        }
                    }
                }
            }
        })
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
    
    static var keyboardWillShow: AnyPublisher<Bool, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { _ in
                return true
            }

        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in
                return false
            }

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
