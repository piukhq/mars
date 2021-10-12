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
    static let vStackInsetsForKeyboard = EdgeInsets(top: 20, leading: 25, bottom: 350, trailing: 25)
    static let vStackSpacing: CGFloat = 20
    static let scrollViewOffsetBuffer: CGFloat = 20
    static let inputToolbarHeight: CGFloat = 44
    static let multipleChoicePickerHeight: CGFloat = 200
    static let graphicalDatePickerHeight: CGFloat = UIDevice.current.isSmallSize ? 370 : 450
    static let datePickerHeight: CGFloat = 230
    static let expiryDatePickerHeight: CGFloat = 180
}

struct FormView: View {
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
                VStack(alignment: .center, spacing: FormViewConstants.vStackSpacing) {
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
                    
                    ForEach(viewModel.datasource.visibleFields) { field in
                        TextfieldView(field: field, viewModel: viewModel)
                    }
                    
                    FormFooterView(datasource: viewModel.datasource)
                }
                .padding(viewModel.vStackInsets)
            }
            .background(Color(Current.themeManager.color(for: .viewBackground)))
            .edgesIgnoringSafeArea(.bottom)
            .offset(y: -viewModel.scrollViewOffsetForKeyboard)
            .onReceive(viewModel.$formInputType) { inputType in
                guard viewModel.didLayoutViews else {
                    viewModel.didLayoutViews = true /// Prevents view animating on first load on iOS 13
                    return
                }
                if case .none = inputType {
                    withAnimation {
                        viewModel.vStackInsets = FormViewConstants.vStackInsets
                        viewModel.scrollViewOffsetForKeyboard = 0
                        return
                    }
                } else {
                    let screenHeight = UIScreen.main.bounds.height
                    let visibleOffset = screenHeight - (viewModel.keyboardHeight + FormViewConstants.inputToolbarHeight)
                    if viewModel.selectedTextfieldYOrigin > visibleOffset {
                        withAnimation {
                            let distanceFromSelectedTextfieldToBottomOfScreen = screenHeight - viewModel.selectedTextfieldYOrigin
                            let distanceFromSelectedTextfieldToTopOfKeyboard = viewModel.keyboardHeight - distanceFromSelectedTextfieldToBottomOfScreen
                            
                            if case .keyboard = inputType {
                                if self.viewModel.scrollViewOffsetForKeyboard != 0.0 {
                                    // Next button on keyboard tapped
                                    let neededOffset = distanceFromSelectedTextfieldToTopOfKeyboard + self.viewModel.scrollViewOffsetForKeyboard + FormViewConstants.scrollViewOffsetBuffer
                                    if neededOffset > viewModel.keyboardHeight {
                                        self.viewModel.scrollViewOffsetForKeyboard = viewModel.keyboardHeight - FormViewConstants.scrollViewOffsetBuffer
                                    } else {
                                        self.viewModel.scrollViewOffsetForKeyboard = neededOffset
                                    }
                                } else {
                                    self.viewModel.scrollViewOffsetForKeyboard = distanceFromSelectedTextfieldToTopOfKeyboard + FormViewConstants.scrollViewOffsetBuffer
                                }
                            } else {
                                // Pickers
                                self.viewModel.scrollViewOffsetForKeyboard = distanceFromSelectedTextfieldToTopOfKeyboard + FormViewConstants.inputToolbarHeight + FormViewConstants.scrollViewOffsetBuffer
                            }
                        }
                    } else {
                        // Selected textfield is visible, but still add padding to vStack so user can scroll to see content below, hidden by keyboard
                        self.viewModel.vStackInsets = FormViewConstants.vStackInsetsForKeyboard
                    }
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
                            .transition(.move(edge: .bottom))
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
                    .pickerStyle(.wheel)
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
                            .frame(width: geometry.size.width / 2, height: FormViewConstants.expiryDatePickerHeight)
                            .clipped()
                            .pickerStyle(.wheel)
                            
                            let yearsMapped = years.map { $0.title }
                            Picker("Expiry date", selection: $pickerTwoSelection.onChange({ _ in
                                viewModel.formatPickerData(pickerOne: pickerOneSelection, pickerTwo: pickerTwoSelection)
                            })) {
                                ForEach(yearsMapped, id: \.self) {
                                    Text($0)
                                }
                            }
                            .background(Color(Current.themeManager.color(for: .viewBackground)))
                            .frame(width: geometry.size.width / 2, height: FormViewConstants.expiryDatePickerHeight)
                            .clipped()
                            .pickerStyle(.wheel)
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
                Rectangle()
                    .foregroundColor(Color(UIColor.grey10))
                FormView(viewModel: FormViewModel(datasource: datasourceMock, title: "Title text", description: "Im a description", membershipPlan: nil))
                    .preferredColorScheme(.light)
            }
        }
    }
}
