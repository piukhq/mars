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

    init(_ field: FormField, text: Binding<String>) {
        self.field = field
        self.text = text
    }

    func makeCoordinator() -> TextfieldUIK.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<TextfieldUIK>) -> UITextField {
        let isEnabled = !field.isReadOnly

        let textfield = UITextField(frame: .zero)
        textfield.textColor = isEnabled ? Current.themeManager.color(for: .text) : .binkDynamicGray
        textfield.placeholder = field.placeholder
        textfield.text = field.forcedValue ?? text.wrappedValue
        textfield.font = .textFieldInput
        textfield.isSecureTextEntry = field.fieldType.isSecureTextEntry
        textfield.keyboardType = field.fieldType.keyboardType()
        textfield.autocorrectionType = field.fieldType.autoCorrection()
        textfield.autocapitalizationType = field.fieldType.capitalization()
        textfield.clearButtonMode = field.fieldCommonName == .barcode ? .always : .whileEditing
        textfield.accessibilityIdentifier = field.title
        
        textfield.delegate = context.coordinator

        context.coordinator.setup(textfield)

        return textfield
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<TextfieldUIK>) {
        uiView.text = self.text.wrappedValue
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: TextfieldUIK

        init(_ textFieldContainer: TextfieldUIK) {
            self.parent = textFieldContainer
        }

        func setup(_ textField:UITextField) {
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }

        @objc func textFieldDidChange(_ textField: UITextField) {
            self.parent.text.wrappedValue = textField.text ?? ""

            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
}
