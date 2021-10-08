//
//  TextfieldViewUIK.swift
//  binkapp
//
//  Created by Sean Williams on 05/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit
import SwiftUI

struct TextfieldUIK: UIViewRepresentable {
    private var field: FormField
    private var text: Binding<String>
    private var onAppear: (UITextField) -> Void
    private var didBeginEditing: (UITextField) -> Void
    private var didEndEditing: (UITextField) -> Void
    private var onCommit: (UITextField) -> Void
    private var clearButtonTapped: () -> Void
    
    var textField = UITextField(frame: .zero)
    
    init(_ field: FormField, text: Binding<String>, onAppear: @escaping (UITextField) -> Void, didBeginEditing: @escaping (UITextField) -> Void, didEndEditing: @escaping (UITextField) -> Void, onCommit: @escaping (UITextField) -> Void, clearButtonTapped: @escaping () -> Void) {
        self.field = field
        self.text = text
        self.didBeginEditing = didBeginEditing
        self.didEndEditing = didEndEditing
        self.onCommit = onCommit
        self.onAppear = onAppear
        self.clearButtonTapped = clearButtonTapped
    }

    func makeCoordinator() -> TextfieldUIK.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<TextfieldUIK>) -> UITextField {
        let isEnabled = !field.isReadOnly

        textField.tintColor = Current.themeManager.color(for: .text)
        textField.textColor = isEnabled ? Current.themeManager.color(for: .text) : .binkDynamicGray
        textField.placeholder = field.placeholder
        textField.text = field.forcedValue ?? text.wrappedValue
        textField.font = .textFieldInput
        textField.isSecureTextEntry = field.fieldType.isSecureTextEntry
        textField.keyboardType = field.fieldType.keyboardType()
        textField.autocorrectionType = field.fieldType.autoCorrection()
        textField.autocapitalizationType = field.fieldType.capitalization()
        textField.clearButtonMode = field.fieldCommonName == .barcode ? .always : .whileEditing
        textField.accessibilityIdentifier = field.title
        textField.smartQuotesType = .no
        textField.delegate = context.coordinator
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        context.coordinator.setup(textField)
        onAppear(textField)
        
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<TextfieldUIK>) {
        uiView.text = text.wrappedValue
    }

    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: TextfieldUIK
        private var pickerSelectedChoice: String?
        
        private lazy var inputAccessory: UIToolbar = {
            let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(accessoryDoneTouchUpInside))
            done.tintColor = .blueAccent
            bar.items = [flexSpace, done]
            bar.sizeToFit()
            return bar
        }()

        init(_ textFieldContainer: TextfieldUIK) {
            self.parent = textFieldContainer
        }

        func setup(_ textField: UITextField) {
            textField.addTarget(self, action: #selector(textFieldUpdated), for: .editingChanged)
            textField.inputAccessoryView = inputAccessory
            
//            if case .expiry(_, _) = parent.field.fieldType {
//    //            textField.inputView = FormMultipleChoiceInput(with: [months, years], delegate: self)
//            } else if case let .choice(data) = parent.field.fieldType {
//                textField.inputView = FormMultipleChoiceInput(with: [data], delegate: self)
////                pickerSelectedChoice = data.first?.title
////                formField?.updateValue(pickerSelectedChoice)
//            } else if case .date = parent.field.fieldType {
//                let datePicker = UIDatePicker()
//                datePicker.datePickerMode = .date
//                datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
//
//                if #available(iOS 14.0, *) {
//                    datePicker.preferredDatePickerStyle = .inline
//                    datePicker.backgroundColor = Current.themeManager.color(for: .viewBackground)
//                    datePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400)
//                }
//
//                textField.inputView = datePicker
//                pickerSelectedChoice = datePicker.date.getFormattedString(format: .dayShortMonthYearWithSlash)
//                parent.field.updateValue(pickerSelectedChoice)
//            } else {
//                textField.inputView = nil
//            }
        }
        
        
        // MARK: - Actions

        @objc func accessoryDoneTouchUpInside() {
            parent.textField.resignFirstResponder()
            textFieldDidEndEditing(parent.textField)
        }

        @objc func textFieldUpdated(_ textField: UITextField) {
            guard let textFieldText = textField.text else { return }
            parent.field.updateValue(textFieldText)
            parent.text.wrappedValue = textField.text ?? ""
        }
        
        @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
            let selectedDate = sender.date.getFormattedString(format: .dayShortMonthYearWithSlash)
            pickerSelectedChoice = selectedDate
            parent.field.updateValue(pickerSelectedChoice)
            parent.text.wrappedValue = selectedDate
        }
        
        
        // MARK: - Delegate methods
        
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            // In order to allow a field to appear disabled, but allow the clear button to still be functional, we cannot make the textfield disabled
            // So we must block the editing instead, which allows the clear button to still work
            return parent.field.isReadOnly == false
        }
        func textFieldShouldClear(_ textField: UITextField) -> Bool {
            if parent.field.fieldCommonName == .barcode {
                parent.clearButtonTapped()
                return false
            }
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.didEndEditing(textField)
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.didBeginEditing(textField)
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onCommit(textField)
            textField.resignFirstResponder()
            return true
        }
    }
}
