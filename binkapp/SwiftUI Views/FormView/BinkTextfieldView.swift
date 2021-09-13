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
    @State var dateString: String
    
//    @Binding var fieldDidExit: Bool
//    @Binding var presentScanner: BarcodeScannerType
//    @Binding var showtextFieldToolbar: Bool
//    @Binding var showDatePicker: Bool
    @Binding var date: Date {
        didSet {
            dateString = String(date.getFormattedString(format: .dayShortMonthYearWithSlash))
        }
    }

    init(field: FormField, viewModel: FormViewModel, date: Binding<Date>) {
        _field = State(initialValue: field)
        self.viewModel = viewModel
        _value = State(initialValue: field.forcedValue ?? "")
        _dateString = State(initialValue: field.placeholder)
//        _fieldDidExit = didExit
//        _presentScanner = presentScanner
//        _showtextFieldToolbar = showToolbar
//        _showDatePicker = showDatePicker
        _date = date
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
                        } else if field.fieldType == .date {
                            HStack {
                                Button {
                                    viewModel.showDatePicker.toggle()
                                } label: {
                                    TextField(field.placeholder, text: $dateString)
                                        .disabled(true)
//                                    Text($dateString.wrappedValue)
                                }
                                Spacer()
                            }
                        } else {
                            TextField(field.placeholder, text: $value, onEditingChanged: { isEditing in
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
                                viewModel.presentScanner = .payment
                            } else {
                                viewModel.presentScanner = .loyalty
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
    
    func convertDateToString(date: Date) {
        dateString = String(date.getFormattedString(format: .dayShortMonthYearWithSlash))
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
