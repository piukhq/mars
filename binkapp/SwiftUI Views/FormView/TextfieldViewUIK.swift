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
    
    let textField = UITextField(frame: .zero)
    
    init(_ field: FormField, text: Binding<String>) {
        self.field = field
        self.text = text
    }

    func makeCoordinator() -> TextfieldUIK.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<TextfieldUIK>) -> UITextField {
        let isEnabled = !field.isReadOnly

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

        context.coordinator.setup(textField)

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<TextfieldUIK>) {
        uiView.text = self.text.wrappedValue
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: TextfieldUIK
        
        private lazy var inputAccessory: UIToolbar = {
            let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(accessoryDoneTouchUpInside))
            bar.items = [flexSpace, done]
            bar.sizeToFit()
            return bar
        }()

        init(_ textFieldContainer: TextfieldUIK) {
            self.parent = textFieldContainer
        }

        func setup(_ textField: UITextField) {
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            textField.inputAccessoryView = inputAccessory
        }
        
        @objc func accessoryDoneTouchUpInside() {
            parent.textField.resignFirstResponder()
            textFieldDidEndEditing(parent.textField)
        }

        @objc func textFieldDidChange(_ textField: UITextField) {
            self.parent.text.wrappedValue = textField.text ?? ""

            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            // Check form validty
//            guard let field = parent.field else { return }
//            validationLabel.text = field.validationErrorMessage != nil ? field.validationErrorMessage : L10n.formFieldValidationError
//            validationLabel.isHidden = field.isValid()
//            isValidationLabelHidden = field.isValid()
//            field.fieldWasExited()
        }
    }
}

fileprivate extension Selector {
    static let textFieldUpdated = #selector(FormCollectionViewCell.textFieldUpdated(_:text:backingData:))
    static let accessoryDoneTouchUpInside = #selector(FormCollectionViewCell.accessoryDoneTouchUpInside)
}
