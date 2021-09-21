//
//  BinkTextfieldView.swift
//  binkapp
//
//  Created by Sean Williams on 10/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Combine
import SwiftUI

struct BinkTextfieldView: View {
    var formViewModel: FormViewModel
    @State var field: FormField
    @State private var isEditing = false
    @State var value: String
    @State var showErrorState = false
    
    init(field: FormField, viewModel: FormViewModel) {
        _field = State(initialValue: field)
        _value = State(initialValue: field.forcedValue ?? "")
        self.formViewModel = viewModel
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
                                    formViewModel.pickerType = .choice(data: data)
                                    isEditing = true
                                } label: {
                                    TextField(data.first?.title ?? "", text: $value)
                                        .disabled(true)
                                        .onReceive(formViewModel.$pickerData) { pickerData in
                                            guard isEditing else { return }
                                            self.value = pickerData.value
                                            self.field.updateValue(pickerData.value)
                                        }
                                }
                                .onReceive(formViewModel.$pickerType) { pickerType in
                                    if case .none = pickerType {
                                        isEditing = false
                                    }
                                }
                                Spacer()
                            }
                        case .date:
                            HStack {
                                Button {
                                    formViewModel.pickerType = .date
                                    isEditing = true
                                } label: {
                                    TextField(field.placeholder, text: $value)
                                        .disabled(true)
                                        .onReceive(formViewModel.$date) { date in
                                            guard isEditing else { return }
                                            let dateString = date.getFormattedString(format: .dayShortMonthYearWithSlash)
                                            self.value = dateString
                                            self.field.updateValue(dateString)
                                            self.isEditing = false
                                            self.formViewModel.datasource.checkFormValidity()
                                        }
                                }
                                .onReceive(formViewModel.$pickerType) { pickerType in
                                    if case .none = pickerType {
                                        isEditing = false
                                    }
                                }
                                Spacer()
                            }
                        case .expiry(let months, let years):
                            HStack {
                                Button {
                                    formViewModel.pickerType = .expiry(months: months, years: years)
                                    isEditing = true
                                } label: {
                                    TextField(field.placeholder, text: $value)
                                        .disabled(true)
                                        .onReceive(formViewModel.$pickerData) { pickerData in
                                            guard isEditing else { return }
                                            self.value = pickerData.value
                                            self.field.updateValue(pickerData.value)
                                            // For mapping to the payment card expiry fields, we only care if we have BOTH
                                            guard pickerData.fieldCount > 1 else { return }
                                            let splitData = pickerData.value.components(separatedBy: "/")
                                            self.formViewModel.addPaymentCardViewModel?.setPaymentCardExpiry(month: Int(splitData.first ?? ""), year: Int(splitData.last ?? ""))
                                        }
                                }
                                .onReceive(formViewModel.$pickerType) { pickerType in
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
                            TextField(field.placeholder, text: $value, onEditingChanged: { isEditing in
                                self.isEditing = isEditing
                                self.field.updateValue(value)
                                self.formViewModel.datasource.checkFormValidity()
                                
                                if isEditing {
//                                    self.datasource.formViewDidSelectField(self)
                                    formViewModel.showtextFieldToolbar = true
                                } else {
                                    self.field.fieldWasExited()
                                }
                                showErrorState = !field.isValid() && !value.isEmpty
                            }, onCommit: {
                                self.showErrorState = true
                            })
                            .onReceive(Just(value)) { _ in valueChangedHandler() }
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
                                formViewModel.toPaymentCardScanner()
                            } else {
                                formViewModel.toLoyaltyScanner()
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
        if formViewModel.datasource.formtype == .addPaymentCard {
            formViewModel.configurePaymentCard(field: field, value: value)
            
            if field.fieldCommonName == .cardNumber {
                configureCardNumberText()
            }
        }
    }
    
    private func configureCardNumberText() {
        guard let newCharacter = value.last else { return }
        let rangesOfLastCharacter = value.ranges(of: String(newCharacter))
        if let rangeOfLastCharacter = rangesOfLastCharacter.last {
            if formViewModel.previousTextfieldValue.count > value.count {
                // If current value length is less than the previous value length then we can assume this is a delete, and if the next character after
                // this one is a whitespace string then let's remove it.
                
                let lastCharacterLocation = rangeOfLastCharacter.location
                if lastCharacterLocation > 0, value.count > lastCharacterLocation {
                    let stringRange = value.index(value.startIndex, offsetBy: lastCharacterLocation)
                    let secondToLastCharacter = value[stringRange]
                    
                    if secondToLastCharacter == " " {
                        var mutableText = value
                        mutableText.remove(at: stringRange)
                        value = mutableText
                    }
                }
            } else {
                if let type = formViewModel.addPaymentCardViewModel?.paymentCardType, field.fieldType == .paymentCardNumber {
                    let newValue = String(newCharacter)
                    let values = type.lengthRange()
                    let cardLength = values.length + values.whitespaceIndexes.count
                    
                    if value.count >= cardLength {
                        value = String(value.prefix(cardLength))
                    }
                    
                    if values.whitespaceIndexes.contains(rangeOfLastCharacter.location) && !newValue.isEmpty {
                        value.removeLast(1)
                        value += " \(newValue)"
                    }
                }
            }
        }
        formViewModel.previousTextfieldValue = value
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
