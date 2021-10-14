//
//  BinkTextfieldView.swift
//  binkapp
//
//  Created by Sean Williams on 10/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Combine
import SwiftUI

struct TextfieldView: View {
    private let formViewModel: FormViewModel
    @State var field: FormField
    @State private var isEditing = false
    @State var value: String
    @State var canShowErrorState = false
    
    init(field: FormField, viewModel: FormViewModel) {
        _field = State(initialValue: field)
        _value = State(initialValue: field.forcedValue ?? "")
        self.formViewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .foregroundColor(Color(Current.themeManager.color(for: .walletCardBackground)))
                
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(field.title)
                            .font(.nunitoSans(15))
                            .foregroundColor(Color(Current.themeManager.color(for: .text)))
                        
                        switch field.fieldType {
                        case .choice(let data):
                            GeometryReader { proxy in
                                HStack {
                                    Button {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        formViewModel.selectedTextfieldYOrigin = proxy.frame(in: .global).maxY
                                        formViewModel.formInputType = .choice(data: data)
                                        isEditing = true
                                    } label: {
                                        TextField(data.first?.title ?? "", text: $value)
                                            .foregroundColor(Color(Current.themeManager.color(for: .text)))
                                            .multilineTextAlignment(.leading)
                                            .disabled(true)
                                            .onReceive(formViewModel.$pickerData) { pickerData in
                                                guard isEditing else { return }
                                                value = pickerData?.title ?? ""
                                                field.updateValue(pickerData?.title)
                                            }
                                    }
                                    .accessibility(identifier: field.title)
                                    .onReceive(formViewModel.$formInputType) { inputType in
                                        if case .choice = inputType {
                                            isEditing = true
                                            if formViewModel.pickerData?.title.isEmpty ?? false {
                                                formViewModel.pickerData = FormPickerData(data.first?.title, backingData: 1)
                                            }
                                        } else {
                                            isEditing = false
                                        }
                                    }
                                    Spacer()
                                }
                                .onAppear {
                                    saveTextFieldToDictionary()
                                }
                            }
                            .frame(height: 24)
                        case .date:
                            GeometryReader { proxy in
                                HStack {
                                    Button {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        formViewModel.selectedTextfieldYOrigin = proxy.frame(in: .global).maxY
                                        formViewModel.formInputType = .date
                                        isEditing = true
                                    } label: {
                                        TextField(field.placeholder, text: $value)
                                            .foregroundColor(Color(Current.themeManager.color(for: .text)))
                                            .multilineTextAlignment(.leading)
                                            .disabled(true)
                                            .onReceive(formViewModel.$date) { date in
                                                guard let date = date else { return }
                                                let dateString = date.getFormattedString(format: .dayShortMonthYearWithSlash)
                                                value = dateString
                                                field.updateValue(dateString)
                                                isEditing = false
                                                formViewModel.datasource.checkFormValidity()
                                            }
                                    }
                                    .accessibility(identifier: field.title)
                                    .onReceive(formViewModel.$formInputType) { inputType in
                                        if case .date = inputType {
                                            isEditing = true
                                        } else {
                                            isEditing = false
                                        }
                                    }
                                    Spacer()
                                }
                                .onAppear {
                                    saveTextFieldToDictionary()
                                }
                            }
                            .frame(height: 24)
                        case .expiry(let months, let years):
                            GeometryReader { proxy in
                                HStack {
                                    Button {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        formViewModel.selectedTextfieldYOrigin = proxy.frame(in: .global).maxY
                                        formViewModel.formInputType = .expiry(months: months, years: years)
                                        isEditing = true
                                    } label: {
                                        TextField(field.placeholder, text: $value)
                                            .foregroundColor(Color(Current.themeManager.color(for: .text)))
                                            .multilineTextAlignment(.leading)
                                            .disabled(true)
                                            .onReceive(formViewModel.$pickerData) { pickerData in
                                                guard isEditing else { return }
                                                value = pickerData?.title ?? ""
                                                field.updateValue(pickerData?.title)
                                                canShowErrorState = true

                                                // For mapping to the payment card expiry fields, we only care if we have BOTH
                                                guard pickerData?.backingData ?? 0 > 1 else { return }
                                                let splitData = pickerData?.title.components(separatedBy: "/")
                                                formViewModel.addPaymentCardViewModel?.setPaymentCardExpiry(month: Int(splitData?.first ?? ""), year: Int(splitData?.last ?? ""))
                                            }
                                    }
                                    .accessibility(identifier: field.title)
                                    .onReceive(formViewModel.$formInputType) { inputType in
                                        if case .expiry = inputType {
                                            isEditing = true
                                        } else {
                                            isEditing = false
                                        }
                                    }
                                    Spacer()
                                }
                                .onAppear {
                                    saveTextFieldToDictionary()
                                }
                            }
                            .frame(height: 24)
                        default:
                            GeometryReader { proxy in
                                TextfieldUIK(field, text: $value, onAppear: { textField in
                                    saveTextFieldToDictionary(textField: textField)
                                }, didBeginEditing: { textField in
                                    isEditing = true
                                    formViewModel.datasource.checkFormValidity()
                                    canShowErrorState = !field.isValid() && !value.isEmpty
                                    formViewModel.selectedTextfieldYOrigin = proxy.frame(in: .global).maxY

                                    if formViewModel.textFields.first(where: { $0.value == textField })?.key == formViewModel.textFields.count - 1 {
                                        textField.returnKeyType = .done
                                    } else {
                                        textField.returnKeyType = .next
                                    }
                                }, didEndEditing: { _ in
                                    isEditing = false
                                    formViewModel.datasource.checkFormValidity()
                                    canShowErrorState = !field.isValid() && !value.isEmpty
                                    field.fieldWasExited()
                                }, onCommit: { textField in
                                    canShowErrorState = true
                                    guard let key = formViewModel.textFields.first(where: { $0.value == textField })?.key else { return }
                                    
                                    if let nextTextField = formViewModel.textFields[key + 1] {
                                        nextTextField.becomeFirstResponder()
                                    } else {
                                        textField.resignFirstResponder()
                                        formViewModel.formInputType = .none
                                    }
                                }, clearButtonTapped: {
                                    formViewModel.textFieldClearButtonTapped = true
                                })
                                .frame(height: 24)
                                .onReceive(Just(value)) { _ in valueChangedHandler() }
                            }
                            .frame(height: 24)
                        } /// << fieldType Switch case
                    } /// << VStack

                    if field.isValid() && !isEditing {
                        Image(Asset.iconCheck.name)
                            .offset(x: -5, y: 11)
                    }
                    
                    // Camera Button
                    if (field.fieldCommonName == .cardNumber || field.fieldCommonName == .barcode) && ((!isEditing && !field.isValid()) || (isEditing && value.isEmpty)) {
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
                                .foregroundColor(Color(Current.themeManager.color(for: .divider)))
                        }
                        .offset(x: -5, y: 11)
                    }
                } /// << HStack
                .padding([.leading, .trailing], 15)
                .background(Color.clear)
                
                Rectangle()
                    .fill(underlineColor())
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 6, alignment: .top)
                    .clipped()
                    .offset(y: 34)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(width: nil, height: 70, alignment: .center)
            
            if textfieldValidationFailed(value: $value) {
                Text(field.validationErrorMessage ?? L10n.formFieldValidationError)
                    .font(.custom(UIFont.textFieldExplainer.fontName, size: UIFont.textFieldExplainer.pointSize))
                    .foregroundColor(Color(.binkDynamicRed))
                    .padding(.leading)
            } /// << ZStack
        } /// << VStack
    } /// << Body
    
    // MARK: - Helper Methods
    
    private func saveTextFieldToDictionary(textField: UITextField? = nil) {
        for (i, datasourceField) in formViewModel.datasource.visibleFields.enumerated() {
            if field.title == datasourceField.title {
                formViewModel.textFields[i] = textField ?? UITextField()
            }
        }
    }
    
    private func valueChangedHandler() {
        if case .addPaymentCard = formViewModel.datasource.formtype {
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
        guard canShowErrorState else { return false }
        return !field.isValid() && !value.wrappedValue.isEmpty
    }
    
    private func underlineColor() -> Color {
        var color: UIColor
        if isEditing {
            color = .activeBlue
            
            if textfieldValidationFailed(value: $value) {
                color = .binkDynamicRed
            }
        } else {
            color = field.isValid() ? .successGreen : .binkDynamicRed
        }
        
        if value.isEmpty && !isEditing {
            color = .clear
        }
        return Color(color)
    }
}

struct BinkTextfieldView_Previews: PreviewProvider {
    static var previews: some View {
        TextfieldView(field: FormField(title: "Email", placeholder: "Enter email Enter emailEnter emailEnter emailEnter emailEnter emailEnter emailEnter emailEnter emailEnter emailEnter emailEnter emailEnter emailEnter emailEnter emailEnter emailEnter email", validation: "", fieldType: .paymentCardNumber, updated: {_,_ in }, shouldChange: {_,_,_,_ in return true }, fieldExited: {_ in }), viewModel: FormViewModel(datasource: FormDataSource(accessForm: .emailPassword), title: "Enter", description: "kjhdskjhsjkhsjkhdsf"))
    }
}
