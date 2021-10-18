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
    static let graphicalDatePickerHeight: CGFloat = UIDevice.current.isSmallSize ? 370 : 410
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
        if #available(iOS 14.0, *) {
            ScrollViewReader { scrollView in
                bodyBuilder()
                    .onReceive(viewModel.$scrollToTextfieldID) { ID in
                        guard let ID = ID else { return }
                        let screenHeight = UIScreen.main.bounds.height
                        let visibleOffset = screenHeight - (viewModel.keyboardHeight + FormViewConstants.inputToolbarHeight)
                        if viewModel.selectedTextfieldYOrigin > visibleOffset {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation {
                                    if viewModel.datasource.visibleFields.count == 1 {
                                        scrollView.scrollTo(ID, anchor: .topTrailing)
                                        switch viewModel.datasource.formtype {
                                        case .authAndAdd, .addPaymentCard:
                                            viewModel.vStackInsets = FormViewConstants.vStackInsetsForKeyboard
                                        default:
                                            break
                                        }
                                        return
                                    }
                                    
                                    if ID == 0 {
                                        scrollView.scrollTo(ID + 1, anchor: .trailing)
                                    } else {
                                        scrollView.scrollTo(ID - 1, anchor: .topTrailing)
                                    }
                                    
                                    switch viewModel.datasource.formtype {
                                    case .authAndAdd, .addPaymentCard:
                                        viewModel.vStackInsets = FormViewConstants.vStackInsetsForKeyboard
                                    default:
                                        break
                                    }
        //                            var idToScrollTo: Int = ID
        //                            if case .date = viewModel.formInputType {
        //                                idToScrollTo += 1
        //                            }
        //
        //                            /// For small screens, scroll to the slected textfield + 1
        //                            if UIDevice.current.isSmallSize && ID != (viewModel.datasource.visibleFields.count - 1) {
        //                                idToScrollTo += 1
        //                                if case .date = viewModel.formInputType {
        //                                    idToScrollTo -= 1
        //                                }
        //                            }
        //
        //                            if UIDevice.current.isSmallSize && ID == viewModel.datasource.visibleFields.count - 1 {
        //                                /// Small device - bottom textfield still hidden, so scroll it to top of screen
        //                                scrollView.scrollTo(idToScrollTo, anchor: .topTrailing)
        //                            } else {
        //                                scrollView.scrollTo(idToScrollTo, anchor: .trailing)
        //                            }
                                }
                            }
                        }
                    }
            }
        } else {
            bodyBuilder()
        }
    }
    
    @ViewBuilder func bodyBuilder() -> some View {
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
//            .edgesIgnoringSafeArea(.bottom)
            .offset(y: -viewModel.scrollViewOffsetForKeyboard)
            
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
            .foregroundColor(.pink)
            .background(Color.clear)
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
