//
//  BinkTextfieldView.swift
//  binkapp
//
//  Created by Sean Williams on 10/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct BinkTextfieldView: View {
    @ObservedObject var viewModel: FormViewModel
    @State var field: FormField
    @State private var isEditing = false
    @State var value: String
    @State var showErrorState = false

    init(field: FormField, viewModel: FormViewModel) {
        _field = State(initialValue: field)
        _value = State(initialValue: field.forcedValue ?? "")
        self.viewModel = viewModel
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
                        
                        switch field.fieldType {
                        case .choice(let data):
                            HStack {
                                Button {
                                    viewModel.pickerType = .choice(data: data)
                                    isEditing = true
                                } label: {
                                    TextField(data.first?.title ?? "", text: $value)
                                        .disabled(true)
                                        .onReceive(viewModel.$pickerData) { pickerData in
                                            guard isEditing else { return }
                                            self.value = pickerData
                                            self.field.updateValue(pickerData)
//                                            self.isEditing = false
                                        }
                                }
                                .onReceive(viewModel.$pickerType) { pickerType in
                                    if case .none = pickerType {
                                        isEditing = false
                                    }
                                }
                                Spacer()
                            }
                        case .date:
                            HStack {
                                Button {
                                    viewModel.pickerType = .date
                                    isEditing = true
                                } label: {
                                    TextField(field.placeholder, text: $value)
                                        .disabled(true)
                                        .onReceive(viewModel.$date) { date in
                                            guard isEditing else { return }
                                            let dateString = date.getFormattedString(format: .dayShortMonthYearWithSlash)
                                            self.value = dateString
                                            self.field.updateValue(dateString)
                                            self.isEditing = false
                                        }
                                }
                                .onReceive(viewModel.$pickerType) { pickerType in
                                    if case .none = pickerType {
                                        isEditing = false
                                    }
                                }
                                Spacer()
                            }
                        case .sensitive, .confirmPassword:
                            SecureField(field.placeholder, text: $value) {
                                self.field.updateValue(value)
                                self.field.fieldWasExited()
                                self.isEditing = false
                            }
                            .onTapGesture {
                                isEditing = true
                            }
                        default:
                            TextField(field.placeholder, text: $value.onChange({ _ in
                                valueChangedHandler()
                            }), onEditingChanged: { isEditing in
                                self.isEditing = isEditing
                                self.field.updateValue(value)
                                self.viewModel.textfieldDidExit = isEditing

                                if isEditing {
//                                    self.datasource.formViewDidSelectField(self)
                                    viewModel.showtextFieldToolbar = true
                                } else {
                                    self.field.fieldWasExited()
                                }
                                showErrorState = !field.isValid() && !value.isEmpty
                            }, onCommit: {
                                self.showErrorState = true
                            })
                            .font(.custom(UIFont.textFieldInput.fontName, size: UIFont.textFieldInput.pointSize))
                            .autocapitalization(field.fieldType.capitalization())
                        }
                    }
                    
                    if field.isValid() && !isEditing {
                        Image(Asset.iconCheck.name)
                            .offset(x: -5, y: 11)
                    }
                    
                    // Camera Button
                    if (field.fieldCommonName == .cardNumber || field.fieldCommonName == .barcode) && !isEditing && !field.isValid() {
                        Button(action: {
                            if field.fieldType == .paymentCardNumber {
                                viewModel.toPaymentCardScanner()
                            } else {
                                viewModel.toLoyaltyScanner()
                            }
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
    
    private func valueChangedHandler() {
        if viewModel.datasource.formtype == .addPaymentCard {
            viewModel.configurePaymentCard(field: field, value: $value)
        }
    }
    
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
