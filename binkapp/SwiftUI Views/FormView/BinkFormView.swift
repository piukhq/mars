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
    
    @ObservedObject var viewModel: FormViewModel
    @ObservedObject private var themeManager = Current.themeManager
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
                            
                        Text(viewModel.descriptionText ?? "")
                            .font(.custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
                            .fixedSize(horizontal: false, vertical: true)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 5)
                    
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
                    
                    FormFooterView(viewModel: viewModel)
                }
                .padding(Constants.vStackInsets)
            }
            .background(Color(themeManager.color(for: .viewBackground)))
            .edgesIgnoringSafeArea(.bottom)
            .padding(.bottom, viewModel.keyboardHeight)
            .onReceive(Publishers.keyboardHeight, perform: { self.viewModel.keyboardHeight = $0 })
            
            // Keyboard Toolbar
            VStack {
                Spacer()
                if viewModel.showtextFieldToolbar {
                    InputToolbarView {
                        viewModel.showtextFieldToolbar = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }

            switch viewModel.pickerType {
            case .date:
                if #available(iOS 14.0, *) {
                    VStack(spacing: 0) {
                        InputToolbarView(buttonAction: { viewModel.pickerType = .none })
                        
                        DatePicker("D.O.B.", selection: $viewModel.date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .frame(maxHeight: 400)
                            .background(Color(themeManager.color(for: .viewBackground)))
                    }
                } else {
                    InputToolbarView(buttonAction: { viewModel.pickerType = .none })

                    DatePicker("D.O.B.", selection: $viewModel.date)
                        .frame(maxHeight: 400)
                        .background(Color(themeManager.color(for: .viewBackground)))
                }
            case .choice(let data):
                VStack(spacing: 0) {
                    InputToolbarView(buttonAction: { viewModel.pickerType = .none })

                    let formData = data.map { $0.title }
                    Picker("Title", selection: $pickerOneSelection.onChange({ _ in
                        viewModel.pickerData = (pickerOneSelection, 1)
                    })) {
                        ForEach(formData, id: \.self) {
                            Text($0)
                        }
                    }
                    .background(Color(themeManager.color(for: .viewBackground)))
                }
                .offset(y: UIApplication.bottomSafeArea)
            case .expiry(let months, let years):
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        Spacer()
                        InputToolbarView(buttonAction: { viewModel.pickerType = .none })
                        
                        HStack(spacing: 0) {
                            let monthsMapped = months.map { $0.title }
                            Picker("Expiry date", selection: $pickerOneSelection.onChange({ _ in
                                viewModel.formatPickerData(pickerOne: pickerOneSelection, pickerTwo: pickerTwoSelection)
                            })) {
                                ForEach(monthsMapped, id: \.self) {
                                    Text($0)
                                }
                            }
                            .background(Color(themeManager.color(for: .viewBackground)))
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
                            .background(Color(themeManager.color(for: .viewBackground)))
                            .frame(width: geometry.size.width / 2)
                            .clipped()
                        }
                    }
//                    .frame(width: geometry.size.width)
                }
            case .none:
                Text("")
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
}

//#if canImport(UIKit)
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}
//#endif
