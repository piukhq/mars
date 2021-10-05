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
    private var placeholder : String
    private var text : Binding<String>

    init(_ placeholder:String, text:Binding<String>) {
        self.placeholder = placeholder
        self.text = text
    }

    func makeCoordinator() -> TextfieldUIK.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<TextfieldUIK>) -> UITextField {

        let textfield = UITextField(frame: .zero)
        textfield.placeholder = placeholder
        textfield.text = text.wrappedValue
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
